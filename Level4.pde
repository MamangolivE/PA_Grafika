// =====================================================
// LEVEL 4 - GOA KRISTAL
// File ini berisi data level dan susunan objek (platform, duri, stalaktit, koin).
// Tema level: goa gelap dengan stalaktit, dan cahaya hanya ada di sekitar bola.
// =====================================================

// Menyimpan data Level 4: nama, tujuan, aturan, ukuran dunia, efek gelap, tetesan air, musik, dan warna.
// Data dikembalikan dalam bentuk objek Level.
Level infoLevel4() {
  Level L = new Level();

  // Identitas dan teks yang ditampilkan pada level
  L.id = 4;
  L.nama = "GOA KRISTAL";
  L.tujuan = "Jelajahi goa gelap. Hanya area di sekitar bola yang bercahaya.";
  L.tip = "Tip: stalaktit menggantung - jangan melompat terlalu tinggi di bawahnya.";

  // Daftar aturan yang muncul pada popup sebelum level dimulai
  L.aturan = new String[] {
    "Goa sangat gelap: cahaya hanya mengikuti bola.",
    "Stalaktit menggantung dari langit-langit. Jangan lompat tinggi di bawahnya!",
    "Platform bergerak makin cepat. Pilih waktu lompat dengan tepat.",
    "Level terakhir! Capai portal untuk menamatkan Bounce."
  };

  // Lebar dunia level serta posisi checkpoint (cpX, cpY) dan ketinggian portal keluar (exitY)
  L.lebar = 4100;
  L.cpX = 2450;
  L.cpY = 560;
  L.exitY = 490;

  // Fisika, cuaca, dan musik. Traksi 0.5 membuat lantai cukup licin.
  // L.gelap = true mengaktifkan efek gelap, sedangkan C_GOA adalah efek cuaca khas goa (tetesan air)
  L.traksi = 0.5;
  L.gelap = true;
  L.tipeCuaca = C_GOA;
  L.indexBgm = 4;

  // Warna tanah, permukaan platform, pencahayaan, dan warna langit-langit goa
  L.cTanah = color(110, 95, 130);
  L.cAtas = color(140, 125, 170);
  L.cAmbient = color(40, 45, 75);
  L.cSinar = color(60, 60, 90);
  L.langitA = color(8, 8, 18);
  L.langitB = color(26, 20, 42);
  return L;
}

// Menyusun semua objek yang ada di Level 4: platform diam dan bergerak, duri, stalaktit, dan koin.
void bangunLevel4() {
  // Platform dengan format (x, y, lebar, tinggi).
  // MovingPlatform adalah platform yang bergerak, dengan tambahan dua nilai di belakang:
  // jarak gerak dan kecepatan geraknya. Kecepatannya makin besar menuju akhir level.
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

  // Rintangan berupa duri di lantai, dengan format (x, y, jumlah duri)
  tambahDuri(1190, 560, 4);
  tambahDuri(2590, 560, 3);
  tambahDuri(3880, 540, 3);

  // Stalaktit yang menggantung dari langit-langit, dengan format (x, y, jumlah)
  tambahStalaktit(1300, 390, 3);
  tambahStalaktit(2800, 300, 3);

  // Koin yang bisa dikumpulkan. Memakai barisKoin dengan format (x, y, jumlah koin, jarak antar koin)
  // agar koin tersusun berderet di atas platform. Tiap koin bernilai +100 skor.
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
