// =====================================================
// LEVEL 3 - ISTANA ES
// File ini berisi data level dan susunan objek (platform, duri, koin).
// Tema level: es dengan lantai yang sangat licin dan platform yang bergerak.
// =====================================================

// Menyimpan data Level 3: nama, tujuan, aturan, ukuran dunia, cuaca es, musik, dan warna.
// Data dikembalikan dalam bentuk objek Level.
Level infoLevel3() {
  Level L = new Level();

  // Identitas dan teks yang ditampilkan pada level
  L.id = 3;
  L.nama = "ISTANA ES";
  L.tujuan = "Seberangi lantai es yang sangat licin dan naiki platform bergerak.";
  L.tip = "Tip: platform kuning di bawahnya bergerak - tunggu waktu yang pas.";

  // Daftar aturan yang muncul pada popup sebelum level dimulai
  L.aturan = new String[] {
    "Lantai es SANGAT licin: mulai mengerem lebih awal.",
    "Platform dengan garis kuning di bawahnya bergerak kiri-kanan.",
    "Kamu ikut terbawa saat berdiri di platform bergerak.",
    "Icicle (duri es) tetap berbahaya. Waspadai tepi platform."
  };

  // Lebar dunia level serta posisi checkpoint (cpX, cpY) dan ketinggian portal keluar (exitY)
  L.lebar = 3600;
  L.cpX = 2350;
  L.cpY = 560;
  L.exitY = 450;

  // Fisika, cuaca, dan musik. Traksi 0.08 membuat lantai sangat licin
  L.traksi = 0.08;
  L.tipeCuaca = C_ES;
  L.indexBgm = 3;

  // Warna tanah, es di atas platform, pencahayaan, dan warna langit
  L.cTanah = color(90, 160, 205);
  L.cAtas = color(190, 240, 255);
  L.cAmbient = color(110, 140, 190);
  L.cSinar = color(200, 235, 255);
  L.langitA = color(10, 25, 60);
  L.langitB = color(60, 150, 190);
  return L;
}

// Menyusun semua objek yang ada di Level 3: platform diam dan bergerak, duri, dan koin.
void bangunLevel3() {
  // Platform dengan format (x, y, lebar, tinggi).
  // MovingPlatform adalah platform yang bergerak, dengan tambahan dua nilai di belakang:
  // jarak gerak dan kecepatan geraknya.
  platforms.add(new Platform(0, 560, 320, 100));
  platforms.add(new Platform(400, 500, 150, 25));
  platforms.add(new Platform(640, 440, 150, 25));
  platforms.add(new MovingPlatform(900, 480, 140, 25, 120, 1.2));
  platforms.add(new Platform(1200, 560, 260, 100));
  platforms.add(new Platform(1540, 490, 160, 25));
  platforms.add(new Platform(1780, 430, 160, 25));
  platforms.add(new MovingPlatform(2010, 470, 150, 25, 130, 1.5));
  platforms.add(new Platform(2330, 560, 300, 100));
  platforms.add(new Platform(2720, 500, 170, 25));
  platforms.add(new Platform(2960, 440, 170, 25));
  platforms.add(new Platform(3200, 500, 400, 100));

  // Rintangan berupa duri es di lantai, dengan format (x, y, jumlah duri).
  tambahDuri(200, 560, 2);
  tambahDuri(1300, 560, 4);
  tambahDuri(2520, 560, 3);
  tambahDuri(3300, 500, 3);

  // Koin yang bisa dikumpulkan. Memakai barisKoin dengan format (x, y, jumlah koin, jarak antar koin)
  // agar koin tersusun berderet di atas platform. Tiap koin bernilai +100 skor.
  barisKoin(100, 505, 3, 60);
  barisKoin(430, 455, 3, 40);
  barisKoin(670, 395, 3, 40);
  barisKoin(940, 430, 3, 45);
  barisKoin(1270, 470, 5, 40);
  barisKoin(1570, 445, 3, 40);
  barisKoin(1810, 385, 3, 40);
  barisKoin(2040, 420, 3, 45);
  barisKoin(2460, 470, 3, 50);
  barisKoin(2750, 455, 3, 40);
  barisKoin(2990, 395, 3, 40);
  barisKoin(3450, 450, 2, 40);
}
