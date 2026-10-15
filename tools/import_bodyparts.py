#!/usr/bin/env python3
"""Build traceable, offline GLBs and 2D renders from BodyParts3D 3.0.

Use: python -m pip install -r tools/asset_requirements.txt
     python tools/import_bodyparts.py --cache /tmp/anatomorph-source

Source geometry and derivatives: CC BY-SA 2.1 Japan. This utility: MIT.
No Z-Anatomy models or noncommercial third-party geometry are used.
"""
import argparse
import concurrent.futures
import csv
import hashlib
import io
import json
import math
from pathlib import Path
import urllib.error
import urllib.request

import numpy as np
from PIL import Image, ImageDraw
import trimesh

ROOT = Path(__file__).resolve().parents[1]
REVISION = 'f0eeb6e843380cfe6b83797cf8c3e1af74de5e61'
BASE = 'https://raw.githubusercontent.com/Kevin-Mattheus-Moerman/BodyParts3D/' + REVISION + '/assets/BodyParts3D_data/'
LICENSE = 'CC-BY-SA-2.1-JP'
CREDIT = 'BodyParts3D, (c) The Database Center for Life Science licensed under CC Attribution-Share Alike 2.1 Japan'

# FMA ontology identifiers, never labels inferred from file names.
MODELS = {
    'brain': ('FMA50801', '#BF943B'),
    'heart': ('FMA7088', '#CA6470'),
    'lungs': (['FMA7333', 'FMA7383', 'FMA7337', 'FMA7370', 'FMA7371'], '#69A0B3'),
    'liver': ('FMA7197', '#AE704D'),
    'stomach': ('FMA7148', '#C58A5E'),
    'small_intestine': (['FMA7206', 'FMA7207', 'FMA7208'], '#C58A5E'),
    'pancreas': ('FMA7198nsn', '#C5935F'),
    'gallbladder': ('FMA7202', '#6B977A'),
    'kidneys': (['FMA7204', 'FMA7205'], '#997CAF'),
    'bladder': ('FMA15900', '#997CAF'),
    'spleen': ('FMA7196', '#6D987A'),
    'thymus': ('FMA9607', '#6D987A'),
    'pituitary': ('FMA13889', '#B78DAC'),
    'adrenal': (['FMA15629', 'FMA15630'], '#B78DAC'),
    'femur': ('FMA24474', '#C5B18B'),
    'biceps': (['FMA37684', 'FMA37686'], '#C97965'),
    'diaphragm': ('FMA13295', '#C97965'),
    'spinal_cord': ('FMA7647', '#BF943B'),
    'testes': (['FMA7211', 'FMA7212'], '#B78DAC'),
}


def download(url, target, optional=False):
    if target.exists():
        return target.read_bytes()
    try:
        with urllib.request.urlopen(url, timeout=45) as response:
            data = response.read()
    except urllib.error.HTTPError as error:
        if optional and error.code == 404:
            return None
        raise
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    return data


def render(mesh, target, back=False):
    """Orthographic surface illustration, frontal/posterior, with diffuse light.

    This is a schematic render of an atlas mesh, never patient imaging.
    """
    vertices = mesh.vertices.copy()
    if back:
        vertices[:, [0, 2]] *= -1
    face_vertices = vertices[mesh.faces]
    # glTF is Y-up. Look along +Z. Smaller Z faces are behind larger Z.
    depth = face_vertices[:, :, 2].mean(axis=1)
    bounds = vertices[:, :2].ptp(axis=0) if hasattr(vertices, 'ptp') else np.ptp(vertices[:, :2], axis=0)
    factor = 430 / max(bounds)
    xy = vertices[:, :2] * factor
    xy[:, 1] *= -1
    xy += np.array([256, 256])
    normal = np.cross(face_vertices[:, 1] - face_vertices[:, 0], face_vertices[:, 2] - face_vertices[:, 0])
    normal /= np.maximum(np.linalg.norm(normal, axis=1)[:, None], 1e-8)
    light = np.array([-.35, .7, .7]); light /= np.linalg.norm(light)
    shade = np.clip(normal @ light, 0, 1) * .52 + .48
    base = np.asarray(mesh.visual.vertex_colors[0][:3], dtype=float)
    image = Image.new('RGB', (512, 512), '#F0F5F1')
    draw = ImageDraw.Draw(image)
    for index in np.argsort(depth):
        points = [tuple(p) for p in xy[mesh.faces[index]]]
        rgb = tuple(np.clip(base * shade[index], 0, 255).astype(int))
        draw.polygon(points, fill=rgb)
    image.save(target, 'WEBP', quality=88, method=6)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cache', type=Path, default=Path('/tmp/anatomorph-source'))
    parser.add_argument('--max-faces', type=int, default=24000)
    args = parser.parse_args()
    cache = args.cache
    data = download(BASE + 'composite_parts.txt', cache / 'composite_parts.txt')
    mapping = {}
    for row in list(csv.reader(io.StringIO(data.decode()), delimiter='\t'))[1:]:
        mapping.setdefault(row[0], set()).add(row[2])

    def fetch(identifier):
        path = cache / (identifier + '.stl')
        data = download(BASE + 'stl/' + identifier + '.stl', path, optional=True)
        if data is None:
            return None
        return identifier, path, hashlib.sha256(data).hexdigest()

    result = []
    for folder in ['models', 'img', 'licenses', 'data']:
        (ROOT / 'assets' / folder).mkdir(parents=True, exist_ok=True)
    for part, (identifiers, color) in MODELS.items():
        ids = set(identifiers if isinstance(identifiers, list) else mapping.get(identifiers, [identifiers]))
        # Composite tables list constituent concepts as well as leaf concepts.
        # Only source STL files actually present are used; non-mesh concepts
        # are explicitly recorded below.
        with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
            candidates = list(pool.map(fetch, sorted(ids)))
        available = [item for item in candidates if item]
        if not available:
            raise RuntimeError('No source geometry for ' + part)
        meshes = [trimesh.load(path, force='mesh') for _, path, _ in available]
        mesh = trimesh.util.concatenate(meshes)
        original_faces = len(mesh.faces)
        if original_faces > args.max_faces:
            mesh = mesh.simplify_quadric_decimation(face_count=args.max_faces)
        # Convert source Z-up coordinates to glTF Y-up, preserving proportions.
        mesh.apply_transform(trimesh.transformations.rotation_matrix(-math.pi / 2, [1, 0, 0]))
        mesh.apply_translation(-mesh.bounds.mean(axis=0))
        mesh.apply_scale(2 / mesh.extents.max())
        rgba = [int(color[i:i+2], 16) for i in (1, 3, 5)] + [255]
        mesh.visual.vertex_colors = rgba
        mesh.metadata.update({'source': 'BodyParts3D 3.0', 'license': LICENSE, 'credit': CREDIT})
        model = ROOT / 'assets/models' / (part + '.glb')
        model.write_bytes(trimesh.exchange.gltf.export_glb(mesh.scene(), include_normals=True))
        if model.stat().st_size >= 2 * 1024 * 1024:
            raise RuntimeError('Model exceeds 2 MB: ' + part)
        images = []
        for view, back in [('front', False), ('back', True)]:
            image = ROOT / 'assets/img' / (part + '_' + view + '.webp')
            render(mesh, image, back)
            images.append({'path': str(image.relative_to(ROOT)), 'sha256': hashlib.sha256(image.read_bytes()).hexdigest()})
        result.append({
            'part': part, 'path': str(model.relative_to(ROOT)), 'license': LICENSE,
            'credit': CREDIT, 'sourceRevision': REVISION,
            'sourceProject': 'https://github.com/Kevin-Mattheus-Moerman/BodyParts3D',
            'sources': [{'id': i, 'url': BASE + 'stl/' + i + '.stl', 'sha256': h} for i, _, h in available],
            'nonMeshConcepts': sorted(ids - {i for i, _, _ in available}),
            'originalFaces': original_faces, 'faces': len(mesh.faces),
            'bytes': model.stat().st_size, 'sha256': hashlib.sha256(model.read_bytes()).hexdigest(),
            'adaptations': 'Composite mesh assembly; quadric decimation to at most 24k triangles; Z-up to Y-up rotation; centering; uniform scale; solid material; orthographic WebP renders.',
            'images': images,
        })
        print(part, 'source meshes:', len(available), 'triangles:', len(mesh.faces), 'bytes:', model.stat().st_size, flush=True)
    (ROOT / 'assets/data/asset_manifest.json').write_text(json.dumps({'schemaVersion': 1, 'assets': result}, indent=2) + '\n')
    license_data = download(BASE + 'LICENSE_content', cache / 'LICENSE_content')
    (ROOT / 'assets/licenses/BodyParts3D.txt').write_bytes(license_data)


if __name__ == '__main__':
    main()
