#!/usr/bin/env python3
"""Original introductory study summaries and schematic art (MIT).

References are linked for study, not copied or republished. Medical and
translation review is pending. Run after the BodyParts3D import.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = 'https://openstax.org/books/anatomy-and-physiology-2e/pages/'
CREDIT = 'BodyParts3D, (c) The Database Center for Life Science licensed under CC Attribution-Share Alike 2.1 Japan. STL conversion: Kevin Mattheus Moerman. GLB adaptation and renders: AnatoMorph.'

DATA = [
    dict(id='brain', name=['Brain','मस्तिष्क','મગજ'], latin='Encephalon', system='nervous', pos=[.5,.085,.23], depth=5, section='13-2-the-central-nervous-system',
         overview='The brain is the central processing organ of the nervous system. The cerebrum, diencephalon, brainstem and cerebellum work together to coordinate conscious experience and essential body functions.',
         function='Integrates sensation, plans and controls movement, supports learning and memory, and regulates autonomic and endocrine activity.',
         location='Inside the cranial cavity, protected by the skull, meninges and cerebrospinal fluid.',
         bloodSupply='Internal carotid and vertebral arteries contribute to the cerebral circulation. Their branches communicate around the base of the brain in the arterial circle.',
         innervation='Neural pathways connect brain regions with the spinal cord and cranial nerves. Brain tissue itself lacks the pain receptors found in surrounding meninges and vessels.',
         clinicalNotes=['Different cerebral regions support different functions; lesion location matters as well as lesion size.','The atlas illustrates a reference surface and does not show an individual patient or every internal brain structure.'],
         questions=[('Which structure is especially important for coordination and balance?', ['Pituitary gland','Cerebellum','Spleen','Urinary bladder'],1,'The cerebellum helps coordinate movement, timing and balance.'),('Where is the brain located?', ['Cranial cavity','Pleural cavity','Pelvic cavity','Peritoneal cavity'],0,'The brain lies within the cranial cavity and is protected by the skull and meninges.')]),
    dict(id='heart', name=['Heart','हृदय','હૃદય'], latin='Cor', system='cardiovascular', pos=[.54,.29,.20], depth=3, section='19-1-heart-anatomy',
         overview='The heart is a muscular pump with two atria and two ventricles. Its right and left sides move blood through the pulmonary and systemic circulations respectively.',
         function='Generates the pressure needed to circulate blood. Valves promote one-way flow, while the conduction system coordinates contractions.',
         location='In the middle mediastinum within the pericardium, between the lungs. Most of its mass lies to the left of the midline.',
         bloodSupply='The right and left coronary arteries arise from the ascending aorta. Most cardiac venous blood returns through the coronary sinus to the right atrium.',
         innervation='Sympathetic cardiac nerves and parasympathetic fibers from the vagus nerve influence rate and conduction. Specialized cardiac cells generate the normal rhythm.',
         clinicalNotes=['Myocardial oxygen delivery depends on coronary circulation; coronary obstruction can injure cardiac muscle.','Heart valves have distinct positions and auscultation areas. A schematic body location is not an auscultation guide.'],
         questions=[('Which chamber normally pumps blood into the aorta?', ['Right atrium','Right ventricle','Left ventricle','Left atrium'],2,'The left ventricle ejects blood into the aorta for systemic circulation.'),('The coronary arteries supply which tissue?', ['Heart muscle','Alveolar air','Bladder lumen','Epidermal surface'],0,'Coronary arteries supply the myocardium with oxygenated blood.')]),
    dict(id='lungs', name=['Lungs','फेफड़े','ફેફસાં'], latin='Pulmones', system='respiratory', pos=[.5,.285,.34], depth=2, section='22-2-the-lungs',
         overview='The paired lungs contain branching airways and alveoli. The right lung usually has three lobes; the left has two and a cardiac notch.',
         function='Provide a large surface for exchange of oxygen and carbon dioxide between alveolar air and pulmonary capillary blood.',
         location='Within the right and left pleural cavities of the thorax, on either side of the mediastinum and above the diaphragm.',
         bloodSupply='Pulmonary arteries carry blood for gas exchange; pulmonary veins return it to the left atrium. Bronchial arteries supply supporting lung tissues.',
         innervation='Pulmonary plexuses carry vagal parasympathetic and sympathetic fibers that influence airway smooth muscle and glands.',
         clinicalNotes=['The pleura and pressure relationships in the thorax are important for ventilation.','A surface mesh cannot display alveolar microstructure or establish respiratory disease.'],
         questions=[('How many lobes does the right lung usually have?', ['One','Two','Three','Four'],2,'The right lung usually has upper, middle and lower lobes.'),('Where does most gas exchange occur?', ['Trachea','Alveoli','Larynx','Main bronchus'],1,'Thin alveolar walls and surrounding capillaries support gas exchange.')]),
    dict(id='liver', name=['Liver','यकृत','યકૃત'], latin='Hepar', system='digestive', pos=[.40,.395,.32], depth=3, section='23-6-accessory-organs-in-digestion-the-liver-pancreas-and-gallbladder',
         overview='The liver is a large gland with important metabolic, synthetic and digestive roles. Its tissue is arranged around an extensive vascular network.',
         function='Produces bile, processes absorbed nutrients, synthesizes many plasma proteins, stores selected nutrients and participates in metabolism of numerous substances.',
         location='Mainly in the right upper abdomen beneath the diaphragm, extending into the epigastric region.',
         bloodSupply='Receives blood from the hepatic artery and hepatic portal vein. Hepatic veins drain into the inferior vena cava.',
         innervation='Autonomic fibers reach the liver through the hepatic plexus, including sympathetic and vagal parasympathetic pathways.',
         clinicalNotes=['Portal blood brings absorbed materials from the digestive tract to the liver.','The liver has several segmental descriptions; the introductory mesh does not identify a surgical resection plane.'],
         questions=[('Which vein delivers much of the absorbed nutrient-rich blood to the liver?', ['Pulmonary vein','Hepatic portal vein','Coronary sinus','Femoral vein'],1,'The hepatic portal vein brings blood from much of the digestive tract to the liver.'),('Which digestive fluid is produced by the liver?', ['Bile','Saliva','Cerebrospinal fluid','Synovial fluid'],0,'The liver produces bile; the gallbladder stores and concentrates it.')]),
    dict(id='stomach', name=['Stomach','आमाशय','જઠર'], latin='Gaster', system='digestive', pos=[.57,.425,.25], depth=4, section='23-4-the-stomach',
         overview='The stomach is a distensible muscular organ between the esophagus and duodenum. Its regions include the cardia, fundus, body and pyloric part.',
         function='Stores a meal temporarily, mixes it into chyme, secretes acid and digestive enzymes, and produces intrinsic factor needed for vitamin B12 absorption.',
         location='Mainly in the left upper abdomen and epigastrium. Shape and position vary with filling and body habitus.',
         bloodSupply='Branches of the celiac arterial system supply the stomach, including gastric, gastro-omental and short gastric arteries. Venous drainage enters the portal system.',
         innervation='Vagal parasympathetic pathways, sympathetic fibers through the celiac plexus and the enteric nervous system regulate activity.',
         clinicalNotes=['The gastric mucosal barrier helps protect tissue from acid and digestive enzymes.','Stomach position changes with filling; the body illustration is an approximate location.'],
         questions=[('The stomach empties directly into which structure?', ['Ileum','Cecum','Duodenum','Colon'],2,'The pyloric outlet of the stomach opens into the duodenum.'),('Intrinsic factor is important for absorption of which vitamin?', ['Vitamin C','Vitamin B12','Vitamin K','Vitamin D'],1,'Intrinsic factor binds vitamin B12 and supports its absorption in the terminal ileum.')]),
    dict(id='small_intestine', name=['Small intestine','छोटी आंत','નાનું આંતરડું'], latin='Intestinum tenue', system='digestive', pos=[.5,.535,.32], depth=4, section='23-5-the-small-and-large-intestines',
         overview='The small intestine consists of the duodenum, jejunum and ileum. Folds, villi and microvilli greatly increase its absorptive surface.',
         function='Completes much of chemical digestion and absorbs most nutrients into blood or lymph.',
         location='Extends from the stomach to the ileocecal junction. The jejunum and ileum form mobile loops in the abdominal cavity.',
         bloodSupply='The duodenum receives pancreaticoduodenal branches from celiac and superior mesenteric territories. Jejunal and ileal branches arise from the superior mesenteric artery.',
         innervation='Enteric circuits coordinate local activity, modified by vagal parasympathetic and sympathetic pathways.',
         clinicalNotes=['The terminal ileum has a particular role in uptake of bile salts and vitamin B12.','A surface atlas does not show the microscopic absorptive structures.'],
         questions=[('Which is the correct proximal-to-distal order?', ['Ileum, jejunum, duodenum','Jejunum, ileum, duodenum','Duodenum, jejunum, ileum','Duodenum, ileum, jejunum'],2,'From the stomach, contents pass through the duodenum, then jejunum, then ileum.'),('Villi mainly increase which property?', ['Absorptive surface area','Bone density','Airway pressure','Cardiac output'],0,'Villi increase the surface available for intestinal absorption.')]),
    dict(id='pancreas', name=['Pancreas','अग्न्याशय','સ્વાદુપિંડ'], latin='Pancreas', system='digestive', pos=[.51,.435,.24], depth=5, section='23-6-accessory-organs-in-digestion-the-liver-pancreas-and-gallbladder',
         overview='The pancreas contains exocrine acini and endocrine islets. Its head, neck, body and tail extend across the upper abdomen.',
         function='Delivers digestive enzymes and bicarbonate to the duodenum. Islet hormones, including insulin and glucagon, help regulate blood glucose.',
         location='Mostly retroperitoneal, posterior to the stomach. The head lies within the duodenal curve and the tail approaches the spleen.',
         bloodSupply='Pancreaticoduodenal arteries supply much of the head. Pancreatic branches of the splenic artery supply much of the body and tail.',
         innervation='Vagal parasympathetic and sympathetic fibers reach the pancreas through abdominal autonomic plexuses.',
         clinicalNotes=['The pancreatic duct and biliary pathways have a close anatomical relationship near the duodenum.','Exocrine and endocrine functions belong to different cellular components within the same organ.'],
         questions=[('Which pancreatic component releases insulin?', ['Acinar cells','Islet beta cells','Pancreatic duct epithelium','Red blood cells'],1,'Beta cells in pancreatic islets release insulin.'),('Most of the pancreas lies in which position?', ['Inside the cranial cavity','Anterior to the sternum','Retroperitoneal','Inside the urinary bladder'],2,'Most of the pancreas is retroperitoneal, behind the stomach.')]),
    dict(id='gallbladder', name=['Gallbladder','पित्ताशय','પિત્તાશય'], latin='Vesica biliaris', system='digestive', pos=[.40,.44,.13], depth=4, section='23-6-accessory-organs-in-digestion-the-liver-pancreas-and-gallbladder',
         overview='The gallbladder is a small hollow organ connected to the biliary ducts by the cystic duct.',
         function='Stores and concentrates bile between meals, then releases it into the biliary pathway.',
         location='In a fossa on the inferior surface of the liver in the right upper abdomen.',
         bloodSupply='Usually supplied by the cystic artery, commonly a branch of the right hepatic artery. Vascular patterns vary.',
         innervation='Autonomic fibers arrive through the celiac and hepatic plexuses, with vagal parasympathetic contributions.',
         clinicalNotes=['Biliary anatomy and arterial branching show clinically important variations.','Gallstones are solid material within the biliary system; a reference mesh is not a way to detect them.'],
         questions=[('The gallbladder mainly stores which substance?', ['Insulin','Urine','Bile','Cerebrospinal fluid'],2,'Bile is produced by the liver and stored and concentrated in the gallbladder.'),('Which duct connects the gallbladder to the biliary tree?', ['Cystic duct','Ureter','Thoracic duct','Pancreatic acinus'],0,'The cystic duct connects the gallbladder with the common hepatic duct pathway.')]),
    dict(id='kidneys', name=['Kidneys','गुर्दे','મૂત્રપિંડ'], latin='Renes', system='urinary', pos=[.5,.455,.30], depth=5, section='25-3-gross-anatomy-of-the-kidney',
         overview='The paired kidneys contain cortex and medulla organized around a collecting system. Nephrons are their functional filtration and processing units.',
         function='Form urine, regulate fluid and electrolyte balance, contribute to acid-base control, and produce hormones involved in blood pressure and red cell production.',
         location='Retroperitoneal on either side of the vertebral column. The right kidney is usually slightly lower than the left.',
         bloodSupply='Renal arteries arise from the abdominal aorta. Renal veins drain into the inferior vena cava.',
         innervation='The renal plexus carries predominantly sympathetic fibers that influence renal vascular tone and other functions.',
         clinicalNotes=['Renal filtration depends on specialized microanatomy that is not visible in a surface model.','The renal hilum transmits vessels, nerves and the pelvis of the collecting system.'],
         questions=[('What is the functional unit of the kidney?', ['Alveolus','Nephron','Osteon','Sarcomere'],1,'Nephrons filter plasma and modify the filtrate through tubular processes.'),('The kidneys are generally located where?', ['Retroperitoneal','Within the pleural cavities','Inside the skull','Within the pericardium'],0,'The kidneys lie behind the peritoneum on the posterior abdominal wall.')]),
    dict(id='bladder', name=['Urinary bladder','मूत्राशय','મૂત્રાશય'], latin='Vesica urinaria', system='urinary', pos=[.5,.625,.18], depth=3, section='25-2-gross-anatomy-of-urine-transport',
         overview='The urinary bladder is a distensible hollow organ with a muscular wall. Ureters enter it, and the urethra carries urine away.',
         function='Stores urine and participates in coordinated emptying through contraction of the detrusor and control of the outlet.',
         location='In the pelvis behind the pubic symphysis when relatively empty. A full bladder extends upward into the lower abdomen.',
         bloodSupply='Vesical branches of the internal iliac arterial system supply the bladder; the exact pattern differs between individuals.',
         innervation='Parasympathetic pelvic splanchnic pathways support detrusor contraction. Sympathetic and somatic pathways participate in storage and outlet control.',
         clinicalNotes=['Bladder size and position change substantially as it fills.','Storage and emptying depend on coordinated neural pathways as well as bladder muscle.'],
         questions=[('Which muscle forms much of the bladder wall?', ['Biceps','Detrusor','Diaphragm','Masseter'],1,'The detrusor is the smooth muscle layer responsible for bladder contraction.'),('Which tubes carry urine from kidneys to bladder?', ['Ureters','Urethrae','Bronchi','Bile ducts'],0,'Ureters convey urine to the bladder; the urethra carries it outward.')]),
    dict(id='spleen', name=['Spleen','प्लीहा','બરોળ'], latin='Lien', system='lymphatic', pos=[.65,.415,.16], depth=3, section='21-1-anatomy-of-the-lymphatic-and-immune-systems',
         overview='The spleen is a lymphoid organ with red pulp and white pulp. It monitors blood rather than filtering lymph.',
         function='Participates in immune responses to blood-borne material, removes aging blood cells and helps recycle their components.',
         location='In the left upper abdomen, adjacent to the stomach and below the diaphragm.',
         bloodSupply='The splenic artery is a branch of the celiac trunk. The splenic vein contributes to formation of the hepatic portal vein.',
         innervation='Autonomic fibers reach the spleen through the splenic plexus and are predominantly sympathetic.',
         clinicalNotes=['The spleen has a close relationship with the lower left ribs and adjacent abdominal organs.','A person can survive without a spleen, but splenic immune functions remain important.'],
         questions=[('The spleen principally filters which fluid?', ['Bile','Urine','Blood','Alveolar air'],2,'The spleen monitors and filters blood; lymph nodes filter lymph.'),('The spleen usually lies in which abdominal region?', ['Left upper','Right lower','Right upper only','Midline pelvis'],0,'The spleen is usually located in the left upper abdomen.')]),
    dict(id='thymus', name=['Thymus','थाइमस','થાઇમસ'], latin='Thymus', system='lymphatic', pos=[.5,.24,.15], depth=4, section='21-1-anatomy-of-the-lymphatic-and-immune-systems',
         overview='The thymus is a primary lymphoid organ with lobules containing a cortex and medulla. It is most prominent earlier in life.',
         function='Provides the environment for development and selection of T lymphocytes.',
         location='Mainly in the anterior superior mediastinum, sometimes extending into the lower neck.',
         bloodSupply='Branches from nearby thoracic and cervical arteries, including internal thoracic and inferior thyroid vessels, contribute to its supply.',
         innervation='Autonomic fibers accompany vessels; immune and endocrine signals are central to thymic function.',
         clinicalNotes=['Thymic tissue normally undergoes age-related involution and increasing fatty replacement.','The reference adult mesh does not represent the typical thymus of every age group.'],
         questions=[('Which lymphocyte type develops in the thymus?', ['T lymphocytes','Red blood cells','Platelets','Neutrophils only'],0,'The thymus supports maturation and selection of T lymphocytes.'),('The thymus is classified as what?', ['A digestive gland','A primary lymphoid organ','A joint','A urinary duct'],1,'The thymus is a primary lymphoid organ; lymph nodes and the spleen are secondary lymphoid organs.')]),
    dict(id='pituitary', name=['Pituitary gland','पीयूष ग्रंथि','પિયૂષ ગ્રંથિ'], latin='Hypophysis', system='endocrine', pos=[.5,.112,.10], depth=6, section='17-3-the-pituitary-gland-and-hypothalamus',
         overview='The pituitary has anterior and posterior components with different developmental origins and functions. It is closely connected to the hypothalamus.',
         function='The anterior pituitary secretes hormones affecting several endocrine organs. The posterior pituitary releases oxytocin and antidiuretic hormone made by hypothalamic neurons.',
         location='In the hypophyseal fossa of the sella turcica at the base of the skull, connected to the hypothalamus by the infundibulum.',
         bloodSupply='Hypophyseal arteries supply the gland. A portal vascular system carries hypothalamic regulatory signals to the anterior pituitary.',
         innervation='Hypothalamic axons extend into the posterior pituitary. Anterior pituitary activity is largely regulated by hormones arriving through portal vessels.',
         clinicalNotes=['The nearby optic chiasm is an important anatomical relationship.','The anterior and posterior components should not be treated as functionally interchangeable.'],
         questions=[('The pituitary sits in which bony feature?', ['Acetabulum','Sella turcica','Glenoid cavity','Vertebral canal'],1,'The pituitary occupies the hypophyseal fossa within the sella turcica.'),('ADH released from the posterior pituitary is synthesized mainly where?', ['Thyroid gland','Spleen','Hypothalamus','Adrenal cortex'],2,'ADH is synthesized in hypothalamic neurons and transported to the posterior pituitary.')]),
    dict(id='adrenal', name=['Adrenal glands','अधिवृक्क ग्रंथियाँ','અધિવૃક્ક ગ્રંથિઓ'], latin='Glandulae suprarenales', system='endocrine', pos=[.5,.405,.24], depth=5, section='17-6-the-adrenal-glands',
         overview='Each adrenal gland has an outer cortex and an inner medulla. These regions produce different groups of hormones.',
         function='The cortex produces steroid hormones, including cortisol and aldosterone. The medulla releases catecholamines during sympathetic activation.',
         location='Retroperitoneal, near the superior poles of the kidneys. The glands have their own capsules and vascular supply.',
         bloodSupply='Superior, middle and inferior suprarenal arterial groups arise from different sources. Each gland usually drains through a major suprarenal vein.',
         innervation='Preganglionic sympathetic fibers directly stimulate adrenal medullary chromaffin cells.',
         clinicalNotes=['Cortex and medulla differ in tissue origin and regulation.','The right and left suprarenal veins have different usual drainage pathways.'],
         questions=[('Which region produces cortisol?', ['Adrenal cortex','Adrenal medulla','Renal pelvis','Splenic pulp'],0,'Cortisol is a steroid hormone produced by the adrenal cortex.'),('Chromaffin cells belong to which region?', ['Thyroid follicle','Adrenal medulla','Kidney glomerulus','Bladder wall'],1,'Chromaffin cells of the adrenal medulla release catecholamines.')]),
    dict(id='femur', name=['Femur','जांघ की हड्डी','જાંઘનું હાડકું'], latin='Femur', system='skeletal', pos=[.43,.735,.25], depth=5, section='8-4-the-lower-limb',
         overview='The femur is the long bone of the thigh. Its head, neck, trochanters, shaft and distal condyles provide articulation and muscle attachment.',
         function='Transfers load between hip and knee and acts as a lever for lower-limb movement.',
         location='Between the hip and knee. Its head articulates with the acetabulum, and its distal end participates in the knee joint.',
         bloodSupply='The proximal femur receives important branches from circumflex femoral vessels; nutrient and periosteal vessels supply the shaft and other regions.',
         innervation='Periosteal and vascular-associated nerves include sensory and autonomic fibers. Nearby joint innervation arises from several lower-limb nerves.',
         clinicalNotes=['Femoral head blood supply is an important anatomical consideration after a femoral neck fracture.','The supplied atlas model is a right femur, centered for viewing.'],
         questions=[('The femoral head articulates with which structure?', ['Acetabulum','Glenoid cavity','Olecranon fossa','Patellar ligament'],0,'The head of the femur articulates with the acetabulum of the hip bone.'),('The femur is a bone of which region?', ['Forearm','Thigh','Skull','Hand'],1,'The femur is the long bone of the thigh.')]),
    dict(id='biceps', name=['Biceps brachii','द्विशिरस्क पेशी','બાઇસેપ્સ સ્નાયુ'], latin='Musculus biceps brachii', system='muscular', pos=[.285,.325,.22], depth=1, section='11-5-muscles-of-the-pectoral-girdle-and-upper-limbs',
         overview='Biceps brachii is a two-headed muscle in the anterior compartment of the arm. Its long and short heads join into a common muscle belly.',
         function='Supinates the forearm and flexes the elbow. It also contributes to shoulder movement and stability.',
         location='Anterior arm, extending from scapular origins to an insertion on the radius and an aponeurotic expansion.',
         bloodSupply='Muscular branches of the brachial artery supply much of the muscle.',
         innervation='Musculocutaneous nerve, mainly through C5 and C6 spinal segments.',
         clinicalNotes=['Biceps is a forearm supinator as well as an elbow flexor.','The supplied geometry represents the long and short heads on the right side.'],
         questions=[('Which nerve supplies biceps brachii?', ['Ulnar nerve','Musculocutaneous nerve','Sciatic nerve','Phrenic nerve'],1,'Biceps brachii is supplied by the musculocutaneous nerve.'),('Which is a major action of biceps brachii?', ['Forearm supination','Ankle plantarflexion','Knee extension','Finger abduction'],0,'Biceps brachii is a powerful supinator, particularly when the elbow is flexed.')]),
    dict(id='diaphragm', name=['Diaphragm','मध्यपट','ઉદરપટલ'], latin='Diaphragma', system='muscular', pos=[.5,.36,.32], depth=2, section='22-3-the-process-of-breathing',
         overview='The diaphragm is a dome-shaped musculotendinous partition between thorax and abdomen. A central tendon connects its muscular portions.',
         function='The principal muscle of inspiration. Contraction increases thoracic volume and contributes to abdominal pressure changes.',
         location='Forms the inferior boundary of the thoracic cavity. Its major openings transmit the vena cava, esophagus and aorta through or behind it.',
         bloodSupply='Several vessels contribute, including inferior phrenic, superior phrenic, pericardiacophrenic and musculophrenic arteries.',
         innervation='Motor supply is through the phrenic nerves, from C3 to C5. Sensory supply includes phrenic and peripheral lower intercostal pathways.',
         clinicalNotes=['The diaphragm moves during breathing; the mesh is a static reference shape.','Phrenic nerve function is essential to normal diaphragmatic contraction.'],
         questions=[('Which nerve provides motor supply to the diaphragm?', ['Phrenic nerve','Median nerve','Optic nerve','Obturator nerve'],0,'The phrenic nerve supplies the diaphragm and arises from C3-C5.'),('Diaphragm contraction during quiet inspiration generally does what?', ['Decreases thoracic volume','Increases thoracic volume','Closes the ureter','Stops venous return'],1,'Contraction flattens the diaphragm and increases thoracic volume.')]),
    dict(id='spinal_cord', name=['Spinal cord','मेरुरज्जु','કરોડરજ્જુ'], latin='Medulla spinalis', system='nervous', pos=[.5,.40,.15], depth=6, section='13-2-the-central-nervous-system',
         overview='The spinal cord is part of the central nervous system. Ascending and descending pathways connect it to the brain, and segmental circuits support reflexes.',
         function='Transmits sensory and motor information and integrates many reflex and autonomic activities.',
         location='Within the vertebral canal. In adults it usually ends near the L1-L2 vertebral level, with nerve roots continuing below.',
         bloodSupply='Anterior and posterior spinal arteries are reinforced by segmental vascular contributions.',
         innervation='Spinal nerve roots connect the cord to peripheral nerves. Gray matter contains neuronal circuits, while white matter contains long pathways.',
         clinicalNotes=['The adult spinal cord is shorter than the vertebral canal; cord segments and vertebral levels are not identical.','The cauda equina consists of nerve roots below the usual end of the cord.'],
         questions=[('The spinal cord lies within which space?', ['Vertebral canal','Pleural cavity','Pericardial cavity','Bladder lumen'],0,'The spinal cord is protected within the vertebral canal.'),('The cauda equina is composed mainly of what?', ['Cerebral lobes','Spinal nerve roots','Cardiac valves','Alveoli'],1,'The cauda equina is a collection of nerve roots below the conus medullaris.')]),
    dict(id='skin', name=['Skin','त्वचा','ત્વચા'], latin='Cutis', system='integumentary', pos=[.17,.46,.15], depth=0, section='5-1-layers-of-the-skin',
         overview='Skin consists of epidermis and dermis, with a subcutaneous layer beneath. The epidermis forms a renewing outer barrier.',
         function='Protects the body, contributes to temperature control, supports sensation and helps initiate vitamin D synthesis.',
         location='Covers the external body surface. Its thickness and appendages vary across regions.',
         bloodSupply='Vessels in the dermis and underlying tissues supply the skin. The epidermis is avascular and receives nutrients by diffusion.',
         innervation='Cutaneous sensory endings detect touch, temperature and other stimuli. Autonomic fibers influence glands and small vessels.',
         clinicalNotes=['Skin depth matters when describing an injury; the epidermis and dermis differ structurally.','The illustration is a simplified cross-section, not a histological specimen. No licensed 3D skin model is bundled.'],
         questions=[('Which layer of skin is avascular?', ['Dermis','Epidermis','Subcutaneous tissue','All layers'],1,'The epidermis contains no blood vessels and is nourished by diffusion from deeper tissues.'),('Which is a major function of skin?', ['Barrier protection','Pumping blood','Producing bile','Filtering urine'],0,'Skin provides a protective barrier and also supports sensation and temperature regulation.')]),
    dict(id='testes', name=['Testes','वृषण','વૃષણ'], latin='Testes', system='reproductive', pos=[.5,.675,.13], depth=3, section='27-1-anatomy-and-physiology-of-the-male-reproductive-system',
         overview='The paired testes contain seminiferous tubules and interstitial tissue. Germ cells, supporting cells and hormone-producing cells have distinct roles.',
         function='Produce sperm in the seminiferous tubules and secrete testosterone mainly from interstitial Leydig cells.',
         location='Within the scrotum, outside the abdominal cavity, with vascular and duct connections through the spermatic cords.',
         bloodSupply='Testicular arteries usually arise from the abdominal aorta. The pampiniform venous plexuses contribute to heat exchange and venous return.',
         innervation='Autonomic fibers reach the testes through the testicular plexuses accompanying their vessels.',
         clinicalNotes=['Scrotal position and vascular heat exchange support the temperature requirements of spermatogenesis.','This entry reflects the male reference dataset. The introductory catalog is not a complete reproductive anatomy atlas.'],
         questions=[('Sperm are produced in which structures?', ['Seminiferous tubules','Renal tubules','Alveoli','Bile ducts'],0,'Spermatogenesis occurs in the seminiferous tubules.'),('Which cells produce much of the testicular testosterone?', ['Sertoli cells','Leydig cells','Red blood cells','Osteocytes'],1,'Interstitial Leydig cells produce testosterone.')]),
]

ART = {
    'brain': '<path d="M50 13C25 5 9 26 13 45C5 63 19 85 40 84L50 90L60 84C82 85 95 64 88 45C92 25 74 5 50 13Z"/><path d="M50 16V86M29 26Q47 24 39 42Q19 41 25 57Q46 52 40 74M70 24Q51 27 61 43Q81 42 75 59Q55 52 61 74" class="line"/>',
    'heart': '<path d="M50 25C71 11 88 33 81 57C77 73 58 88 49 91C34 79 16 68 17 46C17 30 35 18 50 25Z"/><path d="M43 27L40 10L51 8L57 24M56 26L68 12L75 17L66 32"/><path d="M49 30Q42 56 62 76M27 46Q47 40 69 55" class="line"/>',
    'lungs': '<path d="M44 24C31 20 17 32 13 56L11 79Q28 94 45 79ZM56 24C68 20 85 36 89 58L89 81Q72 91 55 77Z"/><path d="M50 9V41M50 40L30 58M50 40L72 58M29 59L20 72M71 58L79 74" class="line"/>',
    'liver': '<path d="M11 35C22 15 52 17 87 26L90 48Q74 66 49 72Q28 73 13 58Z"/><path d="M54 26L50 66M17 43Q33 35 48 38" class="line"/>',
    'stomach': '<path d="M52 9L62 11L60 30C91 17 93 64 70 78C57 90 31 85 25 69L16 74L12 65L30 52Q38 64 46 59C54 54 52 34 52 9Z"/><path d="M68 34Q82 52 60 69M56 68L40 72" class="line"/>',
    'small_intestine': '<path d="M18 25Q11 20 11 33V78Q13 89 24 84L35 78Q40 94 52 83Q63 94 73 81Q91 87 89 69V29Q85 18 73 26Q62 13 51 24Q34 13 27 27Z"/><path d="M27 30Q43 39 27 47Q17 58 34 64Q53 71 39 80M52 27Q72 39 53 48Q37 58 59 64Q76 70 65 79M75 35Q85 49 72 55" class="line"/>',
    'pancreas': '<path d="M15 32Q27 20 39 30L80 35Q97 40 81 50L40 61Q28 80 17 65Q8 50 15 32Z"/><path d="M22 48L78 42M35 36L41 46M37 60L44 47M58 38L60 45" class="line"/>',
    'gallbladder': '<path d="M52 12L62 14L58 34C85 48 73 84 48 89C24 77 22 48 46 34Z"/><path d="M48 38Q34 53 43 71" class="line"/>',
    'kidneys': '<path d="M25 16C4 17 5 78 25 82Q48 79 37 60Q23 49 37 39Q48 19 25 16ZM76 16C96 17 95 78 75 82Q53 79 64 60Q77 49 64 39Q53 19 76 16Z"/><path d="M30 53L41 59L44 91M70 53L59 59L56 91" class="line"/>',
    'bladder': '<path d="M25 14L29 31Q10 37 17 61Q23 84 46 85L46 95H55V85Q78 84 85 61Q94 37 73 31L76 14"/><path d="M31 50Q49 34 70 50M39 66L50 78L64 64" class="line"/>',
    'spleen': '<path d="M65 13C91 33 91 73 58 88C38 96 20 74 22 51Q24 21 65 13Z"/><path d="M64 26Q37 39 39 67M40 43L58 48M40 58L58 65" class="line"/>',
    'thymus': '<path d="M44 18Q26 12 22 35L17 74Q25 93 44 78L48 53L54 78Q76 90 84 73L78 34Q73 14 57 18L50 31Z"/><path d="M34 31L30 70M65 31L70 70" class="line"/>',
    'pituitary': '<path d="M44 11H57L57 50Q82 40 85 64Q86 86 61 87Q33 95 17 77Q8 55 38 51L44 50Z"/><path d="M50 20V55M51 57Q66 69 59 85" class="line"/>',
    'adrenal': '<path d="M10 62L32 17L46 64ZM55 63Q51 17 89 20Q96 50 55 63Z"/><path d="M21 55L32 34L37 55M63 52Q63 32 82 30" class="line"/>',
    'femur': '<path d="M57 9Q74 0 83 15Q85 30 66 29L55 38L48 76Q66 82 59 95Q48 101 41 91Q30 102 23 94Q17 83 33 74L44 35L35 23Q31 11 41 9L52 21Z"/><path d="M51 38L40 73" class="line"/>',
    'biceps': '<path d="M43 5L49 25Q31 27 27 53Q22 75 42 78L44 96H53L55 77Q76 74 69 51Q65 27 54 25L58 5Z"/><path d="M49 32L44 68M57 35L55 67" class="line"/>',
    'diaphragm': '<path d="M8 64Q17 17 52 23Q86 15 94 63L80 80Q66 58 49 61Q34 57 21 80Z"/><path d="M22 62Q47 41 79 63M48 60L50 34" class="line"/>',
    'spinal_cord': '<path d="M43 6H56L56 79L51 94L44 79Z"/><path d="M43 18L28 25M57 18L71 25M43 33L25 41M57 33L73 41M43 48L24 57M57 48L74 57M43 64L28 73M57 64L70 73" class="line"/>',
    'skin': '<path d="M9 24H91V83H9Z"/><path d="M9 40H91M9 58H91M22 68L35 76M48 67L62 78M72 66L84 78" class="line"/><path d="M46 50Q35 27 35 9M52 48Q73 19 67 10" class="line"/>',
    'testes': '<path d="M21 40Q13 56 20 78Q30 97 45 79Q58 59 40 42ZM61 40Q47 57 58 80Q75 95 85 75Q92 51 77 41Z"/><path d="M35 43Q23 18 41 8M68 43Q83 18 64 8M29 56Q42 63 29 77M66 55Q80 65 66 77" class="line"/>',
}

COLORS = {'nervous':'#BA963F','cardiovascular':'#CC6471','respiratory':'#70A8B8','digestive':'#C08B60','urinary':'#9C83BA','lymphatic':'#739B7E','endocrine':'#B98BAB','skeletal':'#BFAC86','muscular':'#CD806A','integumentary':'#C6A28D','reproductive':'#B98BAB'}


def main():
    (ROOT/'assets/svg').mkdir(parents=True, exist_ok=True)
    parts = []
    for item in DATA:
        part = dict(item)
        part['name'] = dict(zip(['en','hi','gu'],part.pop('name')))
        x,y,scale = part.pop('pos')
        part['bodyPosition'] = dict(x=x,y=y,scale=scale)
        part['depthOrder'] = part.pop('depth')
        part['svg'] = 'assets/svg/' + part['id'] + '.svg'
        has_model = (ROOT/'assets/models'/(part['id']+'.glb')).is_file()
        part['model3d'] = 'assets/models/'+part['id']+'.glb' if has_model else None
        part['images'] = ['assets/img/'+part['id']+'_'+view+'.webp' for view in ['front','back']] if has_model else []
        part['modelNote'] = 'A simplified surface model from BodyParts3D 3.0, an adult male reference. Internal structures and anatomical variation are not fully represented. Not to be used for procedural planning.' if has_model else 'Original schematic of skin layers. A 3D skin model is not included.'
        part['attribution'] = CREDIT if has_model else 'Original AnatoMorph schematic illustration, MIT license.'
        section = part.pop('section')
        part['sources'] = [dict(title='OpenStax Anatomy and Physiology 2e',url=REFERENCE+section,section=section.split('-',2)[0]+'.'+section.split('-',2)[1])]
        part['reviewStatus'] = 'medical_review_pending'
        part['quiz'] = [dict(id=part['id']+'_'+str(i+1),q=q,question=q,options=options,answer=answer,explanation=explanation) for i,(q,options,answer,explanation) in enumerate(part.pop('questions'))]
        parts.append(part)
        color=COLORS[part['system']]
        drawing=ART[part['id']].replace('class="line"','fill="none" stroke="#FFFFFF" stroke-opacity=".65" stroke-width="2.5"')
        svg='<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><g fill="'+color+'" stroke="'+color+'" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">'+drawing+'</g></svg>\n'
        (ROOT/part['svg']).write_text(svg)
    (ROOT/'assets/data/parts.json').write_text(json.dumps(dict(schemaVersion=1,contentVersion='1.0.0',contentLanguage='en',reviewStatus='medical_review_pending',parts=parts),ensure_ascii=False,indent=2)+'\n')
    body='<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 260 560"><path fill="#287D72" d="M130 8C107 8 98 25 98 43C98 61 108 73 118 78L117 95L78 106Q64 109 58 135L40 203L21 252Q15 265 22 275L28 266L30 282L38 280L42 258L72 198L83 160L89 239L84 288Q81 314 92 343L97 416L91 496L85 533Q78 548 101 550L117 544L121 502L126 402L130 352L134 402L139 502L143 544L159 550Q182 548 175 533L169 496L163 416L168 343Q179 314 176 288L171 239L177 160L188 198L218 258L222 280L230 282L232 266L238 275Q245 265 239 252L220 203L202 135Q196 109 182 106L143 95L142 78C154 73 162 61 162 43C162 25 153 8 130 8Z"/></svg>\n'
    (ROOT/'assets/svg/body.svg').write_text(body)
    (ROOT/'assets/licenses/Original-artwork.txt').write_text('Original AnatoMorph schematic SVG illustrations and body silhouette. MIT license. These are schematic educational illustrations, not clinical images.\nSee the project LICENSE.\n')
    print('Wrote',len(parts),'structures and',sum(len(p['quiz']) for p in parts),'questions')


if __name__ == '__main__':
    main()
