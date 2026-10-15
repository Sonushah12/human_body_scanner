# Asset provenance and licensing

Application code, original summaries, questions, and schematic SVG illustrations
are licensed under the project MIT license. Third-party assets retain their own
licenses. The in-app **Attributions & licenses** screen and Flutter license screen
display notices. Do not remove either from a release.

## BodyParts3D geometry and derived images

19 bundled GLB surface models and 38 WebP renders originate from **BodyParts3D 3.0
(20110915), The Database Center for Life Science**. This is an adult male reference
dataset. It does not represent every person, anatomical variation, or internal
structure. Skin has an original schematic and no bundled 3D model.

Required credit:

> BodyParts3D, (c) The Database Center for Life Science licensed under CC Attribution-Share Alike 2.1 Japan

License: [CC BY-SA 2.1 Japan](https://creativecommons.org/licenses/by-sa/2.1/jp/).
GLBs, derived renders, and provenance metadata retain this attribution/share-alike
license. Commercial use is allowed subject to its conditions; adapted geometry
and renders must preserve the applicable license. The MIT application license
does not override it.

The STL conversion is from [Kevin Mattheus Moerman's BodyParts3D
mirror](https://github.com/Kevin-Mattheus-Moerman/BodyParts3D), pinned to commit
`f0eeb6e843380cfe6b83797cf8c3e1af74de5e61`. Its `README.md` and
`LICENSE_content` document the original database and license. No Z-Anatomy assets,
Sketchfab assets, or noncommercial kidney/inner-ear models are included.

Adaptations: constituent mesh assembly, quadric simplification to at most 24,000
triangles per structure, coordinate rotation from Z-up to Y-up, centering,
**uniform** scaling, illustrative solid colors, GLB conversion, and orthographic
WebP surface renders. Paired organs retain their reference relative arrangement.
Biceps models contain the right long and short heads; the femur is the right femur.
Non-mesh composite concepts are listed in the manifest, not silently represented
as additional source meshes. Simplification can remove small surface detail.

Every source STL URL and SHA-256, original and final triangle counts, output
SHA-256, image SHA-256, and adaptation statement is recorded in
`assets/data/asset_manifest.json`. Source geometry can be rebuilt with
`tools/import_bodyparts.py`. Redistribute the manifest and notices with the assets.

Publication: Mitsuhashi N, Fujieda K, Tamura T, Kawamoto S, Takagi T, Okubo K.
*BodyParts3D: 3D structure database for anatomical concepts.* Nucleic Acids Res.
2009;37:D782–D785. [doi:10.1093/nar/gkn613](https://doi.org/10.1093/nar/gkn613).

## Text references

The study summaries and 40 questions are original introductory material informed
by standard anatomy facts. Each entry links a relevant section of **OpenStax
Anatomy and Physiology 2e** for further reading. No OpenStax figures or textbook
paragraphs are redistributed. The current upstream
[`openstax/osbooks-anatomy-physiology` LICENSE](https://github.com/openstax/osbooks-anatomy-physiology/blob/main/LICENSE)
is **CC BY-NC-SA 4.0**; do not assume the older CC BY terms in the supplied brief
apply to new imported content. Assess a specific figure/edition separately before
any future reuse. External reference URLs require browser internet access.

All original entries and translations have **medical review pending** status.
Citation is not a claim of endorsement, clinical validation, or medical review.

## Original SVG schematics

The body silhouette and 20 structure SVGs are original AnatoMorph artwork under
MIT. Positions and shapes are schematic and are not precise anatomical overlays,
histological specimens, or diagnostic imagery.

## Fonts

Inter (Rasmus Andersson and contributors), Noto Sans Devanagari and Noto Sans
Gujarati (The Noto Project Authors), and Roboto (The Roboto Project Authors), from
[google/fonts](https://github.com/google/fonts). Roboto supplies Flutter's default
fallback locally so the engine does not request it from a font CDN.
Unmodified variable TTF files are bundled; all are **SIL Open Font License 1.1**.
Notices are under `assets/licenses/*-OFL.txt`; source URLs and file SHA-256 values
are in `assets/data/fonts_manifest.json`.

## Viewer and dependencies

Google model-viewer is **Apache-2.0**. `web/model-viewer.min.js` is the unmodified
script bundled in `model_viewer_plus` 1.10.0. It is served locally, including on
web; there is no runtime CDN dependency. Full Apache notice is bundled.
Flutter, GetX, Hive CE, flutter_svg, flutter_animate, url_launcher and other package
notices are available in the Flutter license screen. Dependency versions are
resolved in `pubspec.lock`.
