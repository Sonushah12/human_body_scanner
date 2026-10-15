#!/usr/bin/env python3
"""Exercise the release UI, real IndexedDB/Hive and offline model loading.

Requires Playwright and Chromium; accepts a local test origin, not a preview.
Buttons are activated through their accessible DOM click action because Flutter
semantics layers can overlap the canvas in headless automation.
"""
import argparse
import json
import re
import shutil
from pathlib import Path
from playwright.sync_api import sync_playwright, expect

parser=argparse.ArgumentParser()
parser.add_argument('--origin',default='http://127.0.0.1:8080')
parser.add_argument('--artifacts',type=Path,default=Path('/tmp/anatomorph-validation'))
args=parser.parse_args();args.artifacts.mkdir(parents=True,exist_ok=True)


def activate(locator):
    locator.first.wait_for(state='attached')
    expect(locator.first).to_be_enabled()
    locator.first.evaluate('(element)=>element.click()')
    locator.page.wait_for_timeout(150)


def accessible_text(page):
    return page.evaluate("document.body.innerText + '\\n' + Array.from(document.querySelectorAll('[aria-label]')).map(e=>e.getAttribute('aria-label')).join('\\n')")


def wait_text(page, value):
    page.wait_for_function("value => (document.body.innerText + '\\n' + Array.from(document.querySelectorAll('[aria-label]')).map(e=>e.getAttribute('aria-label')).join('\\n')).includes(value)",arg=value)


def accessibility(page):
    page.wait_for_function("document.querySelector('flt-glass-pane') !== null")
    page.evaluate("document.querySelector('flt-semantics-placeholder')?.click()")
    page.get_by_role('button',name=re.compile(r'^Explore|^Saved|^Practice|^Settings')).first.wait_for()


with sync_playwright() as playwright:
    executable=shutil.which('chromium') or shutil.which('google-chrome')
    browser=playwright.chromium.launch(executable_path=executable,
        args=['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader'])
    context=browser.new_context(viewport={'width':1440,'height':1000})
    page=context.new_page();errors=[];requests=[]
    page.on('pageerror',lambda error:errors.append(str(error)))
    page.on('request',lambda request:requests.append(request.url))
    page.goto(args.origin,wait_until='networkidle');accessibility(page)
    page.screenshot(path=str(args.artifacts/'desktop-body.png'))
    activate(page.get_by_role('button',name='All structures',exact=True))
    page.wait_for_timeout(650)
    page.screenshot(path=str(args.artifacts/'desktop-grid.png'))
    activate(page.get_by_role('button',name=re.compile(r'^Heart\b')))
    page.get_by_role('button',name='Save structure',exact=True).wait_for()
    activate(page.get_by_role('button',name='Save structure',exact=True))
    page.get_by_role('button',name='Remove saved structure',exact=True).wait_for()
    activate(page.locator('[aria-label="3D model"]'))
    page.wait_for_function("document.querySelector('model-viewer')?.loaded === true",timeout=30000)
    model=page.locator('model-viewer')
    assert model.get_attribute('src').endswith('/heart.glb')
    model_id=model.get_attribute('id')
    model.evaluate("element=>element.cameraOrbit='40deg 70deg 130%'")
    activate(page.get_by_role('button',name='Reset view',exact=True))
    page.wait_for_function("document.querySelector('model-viewer')?.getAttribute('camera-orbit') === '0deg 90deg 105%'")
    assert model.get_attribute('id')==model_id, 'Camera reset unnecessarily recreated the viewer'
    assert model.evaluate('element=>element.loaded'), 'Camera reset discarded the loaded model'
    page.screenshot(path=str(args.artifacts/'heart-3d.png'))
    activate(page.locator('[aria-label="Practice"]'))
    activate(page.get_by_role('button',name='Start practice',exact=True))
    activate(page.get_by_role('button',name='Left ventricle',exact=True))
    activate(page.get_by_role('button',name='Check answer',exact=True))
    wait_text(page,'Correct')
    assert 'The left ventricle ejects blood' in accessible_text(page)
    page.screenshot(path=str(args.artifacts/'quiz-feedback.png'))
    activate(page.get_by_role('button',name=re.compile(r'^Saved\b')))
    page.get_by_role('button',name=re.compile(r'^Heart\b')).first.wait_for()
    page.reload(wait_until='networkidle');accessibility(page)
    activate(page.get_by_role('button',name=re.compile(r'^Saved\b')))
    page.get_by_role('button',name=re.compile(r'^Heart\b')).first.wait_for()
    activate(page.get_by_role('button',name=re.compile(r'^Practice\b')))
    wait_text(page,'Answers recorded')
    text=accessible_text(page)
    assert re.search(r'1\s+Answers recorded',text), 'Quiz progress did not survive reload'
    activate(page.get_by_role('button',name=re.compile(r'^Settings\b')))
    activate(page.locator('[aria-label="Dark"]'))
    activate(page.locator('[aria-label="हिन्दी"]'))
    wait_text(page,'अपनी पसंद चुनें')
    page.screenshot(path=str(args.artifacts/'settings-hindi-dark.png'))
    # Return to English for the offline assertions, while retaining dark mode.
    activate(page.locator('[aria-label="English"]'))
    wait_text(page,'Make it your own')
    page.wait_for_function("navigator.serviceWorker.controller !== null",timeout=30000)
    page.evaluate('navigator.serviceWorker.ready.then(()=>true)')
    assert page.evaluate('navigator.serviceWorker.controller.scriptURL').endswith('/sw.js')
    context.set_offline(True)
    page.reload(wait_until='domcontentloaded');accessibility(page)
    activate(page.get_by_role('button',name=re.compile(r'^Saved\b')))
    activate(page.get_by_role('button',name=re.compile(r'^Heart\b')))
    activate(page.locator('[aria-label="3D model"]'))
    page.wait_for_function("document.querySelector('model-viewer')?.loaded === true",timeout=30000)
    assert page.locator('model-viewer').get_attribute('src').endswith('/heart.glb')
    page.set_viewport_size({'width':390,'height':844})
    page.screenshot(path=str(args.artifacts/'phone-heart-offline.png'))
    assert not errors, errors
    report={
        'result':'passed', 'checks':['desktop body/grid','heart detail','real Hive bookmark persistence',
        'real Hive quiz persistence','question feedback','local GLB rendering','camera reset without reload',
        'Hindi interface','dark theme','service worker offline reload','offline GLB rendering','phone viewport'],
        'pageErrors':errors,'externalAppRequests':[url for url in requests
            if url.startswith(('http://','https://')) and not url.startswith(args.origin)],
    }
    assert not report['externalAppRequests'], report['externalAppRequests']
    (args.artifacts/'browser-report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
    browser.close()
