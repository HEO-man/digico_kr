'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "e6f412bc05a03c50040ff0ee36ec7be5",
"version.json": "d3929dae0c8fe6830afae8bcb4389873",
"index.html": "11213dc66800ab54c2119f7facccbcee",
"/": "11213dc66800ab54c2119f7facccbcee",
"main.dart.js": "0000ed039319ca9a142eb43596c6cbac",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "fbd3f6863b7c14008ecb622c1f8986bf",
"icons/Icon-192.png": "fbd3f6863b7c14008ecb622c1f8986bf",
"icons/Icon-maskable-192.png": "fbd3f6863b7c14008ecb622c1f8986bf",
"icons/Icon-maskable-512.png": "fbd3f6863b7c14008ecb622c1f8986bf",
"icons/Icon-512.png": "fbd3f6863b7c14008ecb622c1f8986bf",
"manifest.json": "322ecce4e79adda8524b3f170fc1bc13",
"assets/AssetManifest.json": "3ee8f8b8ffb1e3d8457047fa6e3efbf2",
"assets/NOTICES": "50ff6bd545be594c6fd7115cc9ef671f",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "c42ed05fc6135a6069b460b70ff8218c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/youtube_player_flutter/assets/speedometer.webp": "50448630e948b5b3998ae5a5d112622b",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "1c35f5b023f7c4463f1840148cafaa9f",
"assets/fonts/MaterialIcons-Regular.otf": "dc58e34a3857a945fbcc8ef9f86aa40e",
"assets/assets/main_ilst_01.png": "4d467016c8c07e41e433709103031da1",
"assets/assets/main_ilst_02.png": "97c27003b79650a0ac41158a69965806",
"assets/assets/main_ilst_03.png": "e7b1a63f47f8d19d3c9aebab53f4fe03",
"assets/assets/main_ilst_04.png": "fbd3f6863b7c14008ecb622c1f8986bf",
"assets/assets/main_ilst_05.png": "dcd1722c5f2be102a3bff95f63b5470d",
"assets/assets/digi_illustration/lucemon/script.json": "6e3807e4bf9b8f1921706bd7fe1c4aad",
"assets/assets/digi_illustration/lucemon/lucemon_ilst.png": "5a7a3be794634a0fa19ca1fd54d0286b",
"assets/assets/digi_illustration/lucemon/skill_02.png": "7ce4c9db5aca8aff970bbcd6da7866c2",
"assets/assets/digi_illustration/lucemon/skill_03.png": "de1b49bdc59ef227da09e80db341cb66",
"assets/assets/digi_illustration/lucemon/skill_01.png": "25230954b9d5907a9359ce63afcb65f1",
"assets/assets/digi_illustration/lucemon/skill_04.png": "bee3e00581b3e2804f3e2c1c3b9100c0",
"assets/assets/digi_illustration/omegamon_mm_sp/script.json": "a74169016dbd755da166b7d0dfa7fcd2",
"assets/assets/digi_illustration/omegamon_mm_sp/omegamon_mm_sp_ilst.png": "d971eb9f1988f93b197a34577789f8d9",
"assets/assets/digi_illustration/omegamon_mm_sp/skill_02.png": "7d7091a24c0b0ab08a5f050f0c34d19c",
"assets/assets/digi_illustration/omegamon_mm_sp/skill_03.png": "dbea429cb3a35576ae7a9f0e2c39d212",
"assets/assets/digi_illustration/omegamon_mm_sp/skill_01.png": "b77f85b896c3bb81a2bd7a267c330004",
"assets/assets/digi_illustration/omegamon_mm_sp/skill_04.png": "85f10f2563d085a3002136be160f2189",
"assets/assets/digi_illustration/nezhamon_cm/script.json": "cab353180f5d8677bb80f39ee927f57e",
"assets/assets/digi_illustration/nezhamon_cm/nezhamon_cm_ilst.png": "2381658fcf13c0d34b15de1e5652f763",
"assets/assets/digi_illustration/nezhamon_cm/skill_02.png": "fafdb8166ec9a8f3831d2300245756f3",
"assets/assets/digi_illustration/nezhamon_cm/skill_03.png": "24b73d94bac29ec18101915f83155793",
"assets/assets/digi_illustration/nezhamon_cm/skill_01.png": "7e6e56a7a19a8fa7cd38b6a04e466596",
"assets/assets/digi_illustration/nezhamon_cm/skill_04.png": "2e00290f3f6af27a754ce3d40ba05504",
"assets/assets/digi_illustration/takutoumon_wm/script.json": "e412507258d449a9db5ca926c475b97c",
"assets/assets/digi_illustration/takutoumon_wm/skill_02.png": "05533ffafb39aef59417da4593655658",
"assets/assets/digi_illustration/takutoumon_wm/skill_03.png": "fbd40a9f86e8ea75119b8f05bf2280a0",
"assets/assets/digi_illustration/takutoumon_wm/skill_01.png": "9f470f9910c843e319e2cdbb99d95f14",
"assets/assets/digi_illustration/takutoumon_wm/skill_04.png": "c009fef05b3ecd85a4b57b24b7952e86",
"assets/assets/digi_illustration/takutoumon_wm/takutoumon_wm_ilst.png": "3f892fa3e27ed9340564b0121d9a6a72",
"assets/assets/digi_illustration/shoutmon_x7/script.json": "3805cc3110507667cfbce97c8823bae2",
"assets/assets/digi_illustration/shoutmon_x7/skill_02.png": "e6fdf3f7fcac1c6f7257f83a6f12c919",
"assets/assets/digi_illustration/shoutmon_x7/shoutmon_x7_ilst.png": "b00ded2d2d9e11601cacac85983a5574",
"assets/assets/digi_illustration/shoutmon_x7/skill_03.png": "c63aafbcccb944f4563dec1fd818c325",
"assets/assets/digi_illustration/shoutmon_x7/skill_01.png": "34c2e3859e8abe392ea50f6f79a3132c",
"assets/assets/digi_illustration/shoutmon_x7/skill_04.png": "b2437d4f46bc19bed3d412e8b6cad69f",
"assets/assets/digi_illustration/erlangmon/script.json": "cd979655d90a75c92e9c8a21781a5a4b",
"assets/assets/digi_illustration/erlangmon/skill_02.png": "7b82da5391868fd05026a5462823e6fc",
"assets/assets/digi_illustration/erlangmon/skill_03.png": "5eda93f52f407506146adbf1344dcc37",
"assets/assets/digi_illustration/erlangmon/skill_01.png": "19d88a8342949812c8b36e67dd2636dc",
"assets/assets/digi_illustration/erlangmon/skill_04.png": "e38350b9c28d9f3d186437e44aad5a36",
"assets/assets/digi_illustration/erlangmon/erlangmon_ilst.png": "8b485493d7824206f994d1354ff8e2ee",
"assets/assets/digi_illustration/digimons.json": "49267e3c76f42fb04ae5896afe8f8297",
"assets/assets/digi_illustration/agumon_bb/script.json": "72afafafbff946f04ae9bfbc158211a9",
"assets/assets/digi_illustration/agumon_bb/agumon_bb_ilst.png": "88aa63504a1a4c9ab8c32de4167434df",
"assets/assets/digi_illustration/agumon_bb/skill_02.png": "4033a578101ce8218607992e917e7131",
"assets/assets/digi_illustration/agumon_bb/skill_03.png": "086aa56bde463197c48ea8fddcda6e52",
"assets/assets/digi_illustration/agumon_bb/skill_01.png": "1e3c10285a13c5b68082fa013eb43916",
"assets/assets/digi_illustration/agumon_bb/header.png": "15e7dbb29c0b537fbdf97223a6e42ff7",
"assets/assets/digi_illustration/agumon_bb/skill_04.png": "c934696ff955f31b83aa2abcf5583dfe",
"assets/assets/digi_illustration/jougamon/script.json": "edc8c94ed535173fb774ade08ea9bd54",
"assets/assets/digi_illustration/jougamon/skill_02_02.png": "d17b19a00f8d7349723bf1afad1b8bf3",
"assets/assets/digi_illustration/jougamon/skill_02_01.png": "96f297cff102db3a8686764f371285f6",
"assets/assets/digi_illustration/jougamon/skill_02.png": "3f9b157ada9c16400122d6ce879b58df",
"assets/assets/digi_illustration/jougamon/skill_03.png": "4756e34e9068039c34a7646de9f3572e",
"assets/assets/digi_illustration/jougamon/skill_01.png": "3de94fe308877b410a674d6d55f8407c",
"assets/assets/digi_illustration/jougamon/skill_04.png": "11f6ed87dd7198986454cc0165fd4ba6",
"assets/assets/digi_illustration/jougamon/jougamon_ilst.png": "e5fc65232b721e1184235416473e47bb",
"assets/assets/digi_illustration/shoutmon_x7_sm/script.json": "5d97d0763355ac5315e7f209197332fd",
"assets/assets/digi_illustration/shoutmon_x7_sm/skill_02.png": "a670d29de7d8fb8aa29d72cb287ee899",
"assets/assets/digi_illustration/shoutmon_x7_sm/skill_03.png": "0fe29e343c2487639008960c79b2b5d8",
"assets/assets/digi_illustration/shoutmon_x7_sm/skill_01.png": "f19e8c52b8b3aa87364faf0e9254775a",
"assets/assets/digi_illustration/shoutmon_x7_sm/skill_04.png": "9c259c03305c81c9a5c7d1d3b7360e7d",
"assets/assets/digi_illustration/shoutmon_x7_sm/shoutmon_x7_sm_ilst.png": "7a7bd350f6d211cca55af683ab6b08e6",
"assets/assets/digi_illustration/shagaramon/script.json": "06cf79aec831b909b904b7ef1863b41b",
"assets/assets/digi_illustration/shagaramon/skill_02.png": "2a9069d18a0f84d6d9773c3561e0d2ef",
"assets/assets/digi_illustration/shagaramon/skill_03.png": "b0e7bd00cc9980e73743955030a6a409",
"assets/assets/digi_illustration/shagaramon/skill_01.png": "35909c720c0f060dffc64a6e157a8376",
"assets/assets/digi_illustration/shagaramon/skill_04.png": "125125b4bd8e6dcb9175d4b311955d06",
"assets/assets/digi_illustration/shagaramon/shagaramon_ilst.png": "ea2832c3fa3fa2298cd099003049043f",
"assets/assets/digi_illustration/takutoumon/takutoumon_ilst.png": "2610723698c1efc496ffcc06a4a4c2cf",
"assets/assets/digi_illustration/takutoumon/script.json": "9aae393ea3de298ab8e5a0b204200301",
"assets/assets/digi_illustration/takutoumon/skill_02.png": "295aba1a5689de219bf4f72def388a99",
"assets/assets/digi_illustration/takutoumon/skill_03.png": "336f3282a5aa7780d85b1f808561caa8",
"assets/assets/digi_illustration/takutoumon/skill_01.png": "9a79096b90455ecd4d3eb64fff5c3e57",
"assets/assets/digi_illustration/takutoumon/skill_04.png": "ae7644699d72d7d0310d4fb593c5889d",
"assets/assets/digi_illustration/header_main_001.png": "a1a3944bf0508cd65b21401812c366d9",
"assets/assets/digi_illustration/core_chip.png": "87a6f9f5970923431e2e04d9fabe6f38",
"assets/assets/digi_illustration/header_main_002.png": "be12a1b46d103b8f2e8342e1ca2bc46e",
"assets/assets/digi_illustration/header_main.png": "97b77492857f928132758e2d6fd2ba96",
"assets/assets/digi_illustration/gabumon_bf/script.json": "3452a4aac0f5d5d5d5e4c0207e3abfe7",
"assets/assets/digi_illustration/gabumon_bf/skill_02.png": "b26df1f02a637f1bee762316f3fb823f",
"assets/assets/digi_illustration/gabumon_bf/skill_03.png": "da529f8ab34f138c98eaa1132f08540b",
"assets/assets/digi_illustration/gabumon_bf/skill_01.png": "60d00e6a5d277e2bc5cf7e4ccbfa50e4",
"assets/assets/digi_illustration/gabumon_bf/skill_04.png": "f5637a6c14d0b7739b519f5d3cf9f1e5",
"assets/assets/digi_illustration/gabumon_bf/gabumon_bf_ilst.png": "ae7554ad0edfbf1df4cb0f8a2c8fcfde",
"assets/assets/digi_illustration/cendrillmon/script.json": "17b260b01d78027a8bd88369941e7dc5",
"assets/assets/digi_illustration/cendrillmon/cendrillmon_ilst.png": "28974b7a40b08e05041038529bbd2725",
"assets/assets/digi_illustration/cendrillmon/skill_02.png": "b40f075611554fbd09dd448634a79104",
"assets/assets/digi_illustration/cendrillmon/skill_03.png": "37119290bb3c03e9cc6e7a299c37e79a",
"assets/assets/digi_illustration/cendrillmon/skill_01.png": "341d6908bbced9f8d8064a23f19a4de2",
"assets/assets/digi_illustration/cendrillmon/skill_04.png": "696815cc146b194efadf9834e8bd4a64",
"assets/assets/digi_illustration/nezhamon/nezhamon_ilst.png": "2519d17536347d023546e422f1667e15",
"assets/assets/digi_illustration/nezhamon/script.json": "3ef121154a3f10d22329ab0ed08b3c0c",
"assets/assets/digi_illustration/nezhamon/skill_02.png": "734caedd64e00461bd019eab9a293927",
"assets/assets/digi_illustration/nezhamon/skill_03.png": "de5b2b4c12e81e76fde9f38b292f6892",
"assets/assets/digi_illustration/nezhamon/skill_01.png": "dfd278995d31b3a4d5222c0ca0217426",
"assets/assets/digi_illustration/nezhamon/skill_04.png": "45578e755f2f9eebce377a58e69bc9d1",
"assets/assets/digi_illustration/alphamon_ouryuken/script.json": "d74106536ebafc2bdfc8245f08787547",
"assets/assets/digi_illustration/alphamon_ouryuken/alphamon_ouryuken_ilst.png": "929f9714458c5a79e356812ebfd3cd3e",
"assets/assets/digi_illustration/alphamon_ouryuken/skill_02.png": "740f248340f53b8be249895e330a8105",
"assets/assets/digi_illustration/alphamon_ouryuken/skill_03.png": "b3a24dafb71762b6db1f21b142991496",
"assets/assets/digi_illustration/alphamon_ouryuken/skill_01.png": "a42c8fa3f5656f401a9eb400dcc68669",
"assets/assets/digi_illustration/alphamon_ouryuken/skill_04.png": "5b6f5782309e94ae6c41b9f3a790f488",
"assets/assets/digi_illustration/omegamon_sp/script.json": "12941acc3167d10ae08692c5d157fd81",
"assets/assets/digi_illustration/omegamon_sp/omegamon_sp_ilst.png": "742621387490546ca3b71cfe89e3dc25",
"assets/assets/digi_illustration/omegamon_sp/skill_02_02.png": "ea7856493076969b0f324daf4aa33b11",
"assets/assets/digi_illustration/omegamon_sp/skill_02_03.png": "d322a3c8166df50f2c651ee7c43cabd3",
"assets/assets/digi_illustration/omegamon_sp/skill_02_01.png": "1c2041e6c4332363cde4af7dc14f3433",
"assets/assets/digi_illustration/omegamon_sp/skill_02.png": "00939dfb57154c7584886829044dd6ee",
"assets/assets/digi_illustration/omegamon_sp/skill_03.png": "52f805f91fc2becb8fbe6787a5c39759",
"assets/assets/digi_illustration/omegamon_sp/skill_01.png": "5d3c3f47d2dfaf830e13e459d304f4e2",
"assets/assets/digi_illustration/omegamon_sp/skill_04.png": "aae731bd2210cb4157272c5a9c107d66",
"assets/assets/digi_illustration/erlangmon_bm/script.json": "0e8806bc8b150dfd295e313600688f34",
"assets/assets/digi_illustration/erlangmon_bm/erlangmon_bm_ilst.png": "27fc258462d45f1c9d19233a2c42cf41",
"assets/assets/digi_illustration/erlangmon_bm/skill_02_02.png": "d772631d2f556ec160d5e12d5c8b5f4f",
"assets/assets/digi_illustration/erlangmon_bm/skill_02_03.png": "1158c104ed870af536c262ff12ddc233",
"assets/assets/digi_illustration/erlangmon_bm/skill_02_01.png": "d772631d2f556ec160d5e12d5c8b5f4f",
"assets/assets/digi_illustration/erlangmon_bm/skill_02.png": "d772631d2f556ec160d5e12d5c8b5f4f",
"assets/assets/digi_illustration/erlangmon_bm/skill_03.png": "31b1a89296bc539f79a64d5aa5bfc98b",
"assets/assets/digi_illustration/erlangmon_bm/skill_01.png": "7b8b6dcff41b0e42b5021b71c8d5908e",
"assets/assets/digi_illustration/erlangmon_bm/skill_04.png": "e7650c05d689de8e60531183680dbb43",
"assets/assets/icon/ic_missing.png": "3bae99d9f9547baf9e5a559e2232c8ee",
"assets/assets/icon/app_icon.png": "3bae99d9f9547baf9e5a559e2232c8ee",
"assets/assets/icon/element/ic_wind.png": "935f99c64769cf110013e31387822c7c",
"assets/assets/icon/element/ic_light.png": "d9e60f5c83235a56d329689b69a71a23",
"assets/assets/icon/element/ic_fire.png": "88b3d3977f3f775903364b035a6965cb",
"assets/assets/icon/element/ic_nature.png": "d841768bc2b43ad5ea9d62ab0256ad6f",
"assets/assets/icon/element/ic_water.png": "96d7a988f0f35f286f9bbc6326024975",
"assets/assets/icon/element/ic_dark.png": "7c6cb75a4fcdb0a38795ce85b554afa0",
"assets/assets/icon/element/ic_earth.png": "17029d28e913e83f8750d41a4cd9b2e9",
"assets/assets/icon/element/ic_thunder.png": "24d985fef707ada09951fa6ec30d5875",
"assets/assets/icon/grade/grade_22.png": "7757e7144f63025c6ad32487145e0b40",
"assets/assets/icon/grade/grade_8.png": "acb84778d644ab4a519ea896d07cae53",
"assets/assets/icon/grade/grade_18.png": "7619dbf9a655dd17a4980444688685dd",
"assets/assets/icon/grade/grade_25.png": "457d3f44310e6a7c03e4d17b98fe8871",
"assets/assets/icon/grade/grade_14.png": "3fea070c855e4cc4066d29bfc3e10232",
"assets/assets/icon/grade/grade_11.png": "5386874bab2c94872275065f4abae480",
"assets/assets/icon/type/ic_virus.png": "4c51df8090eb9f35007920ee9ef9ee16",
"assets/assets/icon/type/ic_vaccine.png": "4e7620e6bd8750e07113a79314c4d4fa",
"assets/assets/icon/type/ic_data.png": "c772b1cca1469d5bfdb2704f8544532a",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
