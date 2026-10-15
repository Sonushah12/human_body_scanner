#!/usr/bin/env python3
"""Check catalog integrity, asset provenance, GLB structure and bundle budgets.

This verifies asset/content structure. It does not certify medical accuracy.
Only Python's standard library is required.
"""
import hashlib
import json
from pathlib import Path
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SYSTEMS = {'skeletal','muscular','nervous','cardiovascular','respiratory','digestive','urinary','endocrine','lymphatic','integumentary','reproductive'}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def asset(root, path, digest=None):
    resolved = (root/path).resolve()
    require(resolved.is_relative_to(root.resolve()) and resolved.is_file(), 'Missing or unsafe asset: '+path)
    data = resolved.read_bytes()
    if digest:
        require(hashlib.sha256(data).hexdigest()==digest, 'Asset checksum mismatch: '+path)
    return data


def glb(data, name):
    require(len(data)>=20, 'Truncated GLB: '+name)
    magic,version,size = struct.unpack_from('<4sII', data)
    require(magic==b'glTF' and version==2 and size==len(data), 'Invalid GLB header: '+name)
    offset=12; chunks={}
    while offset<len(data):
        length,kind=struct.unpack_from('<II',data,offset);offset+=8
        require(length%4==0 and offset+length<=len(data), 'Invalid GLB chunk: '+name)
        chunks[kind]=data[offset:offset+length];offset+=length
    require(0x4E4F534A in chunks and 0x004E4942 in chunks,'Missing GLB data: '+name)
    doc=json.loads(chunks[0x4E4F534A]);binary=chunks[0x004E4942]
    require(doc['asset']['version']=='2.0','Unsupported glTF: '+name)
    require(len(binary)>=doc['buffers'][0]['byteLength'],'Missing buffer bytes: '+name)
    for view in doc.get('bufferViews',[]):
        require(view.get('byteOffset',0)+view['byteLength']<=len(binary),'Buffer view outside GLB: '+name)
    require(doc.get('meshes'),'GLB has no renderable mesh: '+name)
    triangles=0
    for mesh in doc['meshes']:
        for primitive in mesh['primitives']:
            require(primitive.get('mode',4)==4,'Expected triangle geometry: '+name)
            require('POSITION' in primitive['attributes'],'Missing geometry positions: '+name)
            positions=doc['accessors'][primitive['attributes']['POSITION']]
            require(positions['count']>0,'Empty geometry: '+name)
            if 'indices' in primitive:triangles+=doc['accessors'][primitive['indices']]['count']//3
            else:triangles+=positions['count']//3
    require(0<triangles<=30000,'Triangle budget exceeded: '+name)
    return triangles


def validate(root=ROOT):
    catalog=json.loads(asset(root,'assets/data/parts.json'))
    require(catalog['schemaVersion']==1,'Unsupported catalog schema')
    parts=catalog['parts'];ids=[p['id'] for p in parts]
    require(len(ids)==20 and len(set(ids))==20,'Expected 20 unique structures')
    require({p['system'] for p in parts}==SYSTEMS,'Incomplete body systems')
    question_ids=[]
    for part in parts:
        require(set(part['name'])=={'en','hi','gu'},'Missing localized names: '+part['id'])
        x,y,scale=part['bodyPosition'].values()
        require(0<=x<=1 and 0<=y<=1 and 0<scale<=1,'Invalid anatomical position')
        ET.fromstring(asset(root,part['svg']))
        require(part['sources'] and all(s['url'].startswith('https://') for s in part['sources']),'Missing references')
        for field in ['overview','function','location','bloodSupply','innervation','attribution']:
            require(bool(part[field]),'Missing study field '+field)
        for question in part['quiz']:
            question_ids.append(question['id'])
            require(0<=question['answer']<len(question['options']),'Invalid quiz answer')
            require(len(set(question['options']))==len(question['options']),'Duplicate answer options')
    require(len(question_ids)==40 and len(set(question_ids))==40,'Expected 40 distinct questions')
    manifest=json.loads(asset(root,'assets/data/asset_manifest.json'))
    require(len(manifest['assets'])==19,'Expected 19 licensed atlas models')
    by_id={p['id']:p for p in parts}
    for entry in manifest['assets']:
        data=asset(root,entry['path'],entry['sha256'])
        require(len(data)<2*1024*1024,'Model exceeds 2 MB: '+entry['part'])
        require(glb(data,entry['part'])==entry['faces'],'Incorrect triangle record')
        require(entry['license']=='CC-BY-SA-2.1-JP' and entry['credit'],'Missing model license')
        require(by_id[entry['part']]['model3d']==entry['path'],'Catalog/model mismatch')
        require(entry['sources'] and all(len(s['sha256'])==64 for s in entry['sources']),'Missing source checksums')
        require(set(i['path'] for i in entry['images'])==set(by_id[entry['part']]['images']),'Missing render provenance')
        for image in entry['images']:asset(root,image['path'],image['sha256'])
    for font in json.loads(asset(root,'assets/data/fonts_manifest.json')):
        asset(root,font['path'],font['sha256'])
        require(font['license']=='SIL-OFL-1.1','Missing font license')
    for notice in ['BodyParts3D.txt','Inter-OFL.txt','Roboto-OFL.txt','NotoSansDevanagari-OFL.txt','NotoSansGujarati-OFL.txt','model-viewer.txt','Original-artwork.txt']:
        asset(root,'assets/licenses/'+notice)
    total=sum(p.stat().st_size for p in (root/'assets').rglob('*') if p.is_file())
    require(total<20*1024*1024,'Bundled content exceeds 20 MB content budget')
    print('Validated: 20 structures, 11 systems, 40 questions, 19 GLBs, 38 renders, 4 fonts.')
    print('Bundled assets:',round(total/1024/1024,2),'MiB. Medical review remains pending.')


if __name__=='__main__':
    validate()
