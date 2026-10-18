// =====================================================
// LEVEL 4 - GOA KRISTAL
//   Data level, susunan objek, dan latar. Tema: goa gelap, stalaktit, cahaya hanya di sekitar bola.
// =====================================================

// Fungsi infoLevel4: Data Level 4 Goa Kristal: gelap, tetesan air, cahaya hanya di sekitar bola.
Level infoLevel4() {
  Level L = new Level();
  // Identitas dan teks level.
  L.id = 4;
  L.nama = "GOA KRISTAL";
  L.tujuan = "Jelajahi goa gelap. Hanya area di sekitar bola yang bercahaya.";
  L.tip = "Tip: stalaktit menggantung - jangan melompat terlalu tinggi di bawahnya.";
  // Daftar aturan yang tampil di popup.
  L.aturan = new String[] {
    "Goa sangat gelap: cahaya hanya mengikuti bola.",
    "Stalaktit menggantung dari langit-langit. Jangan lompat tinggi di bawahnya!",
    "Platform bergerak makin cepat. Pilih waktu lompat dengan tepat.",
    "Level terakhir! Capai portal untuk menamatkan Bounce."
  };
  // Ukuran dunia, posisi checkpoint dan portal.
  L.lebar = 4100;
  L.cpX = 2450;
  L.cpY = 560;
  L.exitY = 490;
  // Fisika, cuaca, dan musik.
  L.traksi = 0.5;
  L.gelap = true;
  L.tipeCuaca = C_GOA;
  L.indexBgm = 4;
  // Warna platform, cahaya, dan langit.
  L.cTanah = color(110, 95, 130);
  L.cAtas = color(140, 125, 170);
  L.cAmbient = color(40, 45, 75);
  L.cSinar = color(60, 60, 90);
  L.langitA = color(8, 8, 18);
  L.langitB = color(26, 20, 42);
  return L;
}

// Fungsi bangunLevel4: Menyusun objek Level 4: platform bergerak, duri, stalaktit, dan koin.
void bangunLevel4() {
  // Platform: x, y, lebar, tinggi (MovingPlatform = bergerak).
  platforms.add(new Platform(0, 560, 300, 100));
  platforms.add(new Platform(380, 510, 140, 25));
  platforms.add(new Platform(600, 450, 140, 25));
  platforms.add(new MovingPlatform(820, 490, 130, 25, 150, 1.6));
  platforms.add(new Platform(1130, 560, 240, 100));
  platforms.add(new Platform(1450, 500, 150, 25));
  platforms.add(new Platform(1680, 440, 150, 25));
  platforms.add(new Platform(1910, 500, 150, 25));
  platforms.add(new MovingPlatform(2150, 460, 140, 25, 130, 1.8));
  platforms.add(new Platform(2430, 560, 260, 100));
  platforms.add(new Platform(2780, 490, 150, 25));
  platforms.add(new Platform(3010, 430, 150, 25));
  platforms.add(new Platform(3240, 490, 150, 25));
  platforms.add(new MovingPlatform(3480, 450, 140, 25, 140, 2.0));
  platforms.add(new Platform(3780, 540, 320, 100));

  // Rintangan: duri lantai (x, y, jumlah) dan stalaktit menggantung.
  tambahDuri(1190, 560, 4);
  tambahDuri(2520, 560, 3);
  tambahDuri(3880, 540, 3);

  tambahStalaktit(1300, 390, 3);
  tambahStalaktit(2800, 300, 3);

  // Koin yang bisa dikumpulkan (+100 skor).
  barisKoin(150, 505, 3, 60);
  barisKoin(410, 455, 2, 40);
  barisKoin(630, 395, 2, 40);
  barisKoin(850, 430, 4, 45);
  barisKoin(1200, 470, 4, 30);
  barisKoin(1480, 445, 3, 40);
  barisKoin(1710, 385, 3, 40);
  barisKoin(1940, 445, 3, 40);
  barisKoin(2170, 405, 3, 40);
  barisKoin(2480, 470, 4, 50);
  barisKoin(2810, 435, 3, 40);
  barisKoin(3040, 375, 3, 40);
  barisKoin(3270, 435, 3, 40);
  barisKoin(3500, 395, 3, 40);
  barisKoin(3850, 470, 4, 40);
}

// Fungsi latarLevel4: Latar Level 4 memakai gambar bg4.png.
void latarLevel4() {
  gambarBg(4, cameraX * 0.3, lv.langitA, lv.langitB);
}

