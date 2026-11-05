# The Nemesis — karakter R15 untuk Roblox Studio

Karakter 3D dari model sheet **ROBLOX UGC BUNDLE: THE NEMESIS**.

Yang dibangun script ini (bukan gambar diam):

- Rig **R15** lengkap (15 bagian + HumanoidRootPart) dengan Motor6D
- Kepala botak, jahitan, mata cekung, rahang + taring
- Coat kulit hitam, hem robek, kerah, sabuk, harness
- Mutasi daging di **bahu kanan**, canister zaitun di dada, selang hijau
- Tentakel punggung (bergerak), tanduk kiri
- Gauntlet, jari, boots dua gesper
- Rocket launcher (moncong, karat, kain merah, gagang kayu, selang) di punggung / tangan
- Animasi prosedural: napas, jalan berat, lompat, hantam, raung, tembak, mati
- Boss AI + pad morph supaya pemain bisa jadi Nemesis

Lua **tidak bisa** memahat mesh UGC seperti Blender. Ini karakter 3D sungguhan di Studio, disusun dari Part, siap dimainkan. Titik tempel aksesori sudah memakai nama R15 (`BodyBackAttachment`, `RightShoulderAttachment`, `HatAttachment`, dan seterusnya) kalau nanti mau diganti MeshPart hasil upload.

## Direktori

```text
TheNemesis/
├── default.project.json          ← peta Rojo (kalau dipakai)
├── README.md
└── src/
    ├── ReplicatedStorage/
    │   └── TheNemesis/           ← ModuleScript "TheNemesis"
    │       ├── init.lua          ← isi ModuleScript induk
    │       ├── Config.lua
    │       ├── Util.lua
    │       ├── RigBuilder.lua
    │       ├── Visuals.lua
    │       └── Gear.lua
    ├── ServerScriptService/
    │   └── NemesisServer.server.lua
    └── StarterPlayer/
        └── StarterPlayerScripts/
            └── NemesisAnimator.client.lua
```

Di Explorer Studio harus jadi:

```text
ReplicatedStorage
└── TheNemesis                 ModuleScript   (tempel init.lua)
    ├── Config                 ModuleScript
    ├── Util                   ModuleScript
    ├── RigBuilder             ModuleScript
    ├── Visuals                ModuleScript
    └── Gear                   ModuleScript
ServerScriptService
└── NemesisServer              Script         (bukan ModuleScript)
StarterPlayer
└── StarterPlayerScripts
    └── NemesisAnimator        LocalScript
```

Nama instance **tanpa** akhiran `.lua` / `.server` / `.client`. Anak-anaknya harus berada **di dalam** ModuleScript `TheNemesis`, bukan di sampingnya.

## Pasang manual (tanpa Rojo)

1. Buka place di Roblox Studio (Baseplate biasa sudah cukup).
2. Di ReplicatedStorage buat **ModuleScript**, namai `TheNemesis`. Hapus isi bawaan, tempel `init.lua`.
3. Klik kanan `TheNemesis` → Insert Object → ModuleScript, empat kali. Namai persis: `Config`, `Util`, `RigBuilder`, `Visuals`, `Gear`. Tempel file yang sesuai.
4. Di ServerScriptService buat **Script** `NemesisServer`. Tempel `NemesisServer.server.lua`.
5. Di StarterPlayer → StarterPlayerScripts buat **LocalScript** `NemesisAnimator`. Tempel `NemesisAnimator.client.lua`.
6. Tekan **Play**.

Boss muncul di depan SpawnLocation. Pad merah di sampingnya.

## Pasang dengan Rojo

Dari folder proyek ini:

```bash
rojo serve
```

Lalu sambungkan plugin Rojo di Studio. Atau:

```bash
rojo build -o TheNemesis.rbxlx
```

## Main

| Aksi | Kontrol |
|---|---|
| Jadi Nemesis | Injak pad, atau ketik `/nemesis` |
| Balik ke avatar biasa | `/human` (atau mati, lalu respawn) |
| Hantam | tombol **HANTAM** atau `F` / tombol X gamepad |
| Raung | tombol **RAUNG** atau `R` / tombol Y |
| Roket | tombol **TEMBAK**, atau klik saat Rocket Launcher terpasang |

Boss sendiri mengejar, menghantam jarak dekat, menembak jarak jauh, dan menyentuh pemain juga memberi damage.

## Yang paling sering diubah

Semua ada di `Config.lua`:

- `Scale` — ukuran. `1` sudah disetel ke proporsi model sheet.
- `Boss.Health`, `WalkSpeed`, `ChaseSpeed`, jarak aggro / melee / roket
- `Combat` — damage, cooldown, radius ledakan
- `JawSign` — kalau mulut tertutup saat raung, ganti `1` jadi `-1`
- `Tentacles` — jumlah ruas, ketebalan, arah `offset`, dan tabel `curl`
- `Sounds` — ganti SoundId kalau mau suara sendiri
- `SpawnBoss` / `SpawnPad` — `false` untuk mematikan boss atau pad

Arah senjata di tangan ada di `Gear.lua`, variabel `handOffset`. Laras senjata adalah sumbu **+X** `GunRoot`.

## Catatan rig

- Sendi memakai **Motor6D** supaya animasi prosedural bisa jalan. Jangan andalkan Animate bawaan Roblox untuk karakter ini; LocalScript sengaja mematikan skrip `Animate` hanya pada karakter Nemesis.
- Pose dihitung di setiap klien dari arah gerak + attribute server (`Action`, `LookAt`, `GunDrawn`), jadi pemain lain juga melihat tentakel dan langkahnya.
- `HipHeight` dihitung dari sol sepatu supaya kaki tidak melayang atau tertanam.
