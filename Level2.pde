// =====================================================
// LEVEL 2 - GUNUNG SALJU
//   Data level, susunan objek, dan latar. Tema: salju, lantai agak licin.
// =====================================================

// Fungsi infoLevel2: Data Level 2 Gunung Salju: lantai agak licin, cuaca salju.
Level infoLevel2() {
  Level L = new Level();
  // Identitas dan teks level.
  L.id = 2;
  L.nama = "GUNUNG SALJU";
  L.tujuan = "Daki lereng bersalju dan capai portal. Salju membuat bola sedikit meluncur.";
  L.tip = "Tip: lepas tombol lebih awal agar bola tidak meluncur ke duri.";
  // Daftar aturan yang tampil di popup.
  L.aturan = new String[] {
    "Lantai bersalju agak licin: bola meluncur setelah tombol dilepas.",
    "Duri es lebih rapat - hitung jarak lompatanmu.",
    "Checkpoint menyimpan posisi saat kamu kehilangan nyawa.",
    "Kumpulkan semua koin untuk skor tertinggi."
  };
  // Ukuran dunia, posisi checkpoint dan portal.
  L.lebar = 3400;
  L.cpX = 2200;
  L.cpY = 560;
  L.exitY = 450;
  // Fisika, cuaca, dan musik.
  L.traksi = 0.35;
  L.tipeCuaca = C_SALJU;
  L.indexBgm = 2;
  // Warna platform, cahaya, dan langit.
  L.cTanah = color(110, 130, 165);
  L.cAtas = color(245, 250, 255);
  L.cAmbient = color(150, 165, 190);
  L.cSinar = color(235, 240, 255);
  L.langitA = color(150, 190, 230);
  L.langitB = color(235, 245, 255);
  return L;
}

// Fungsi bangunLevel2: Menyusun objek Level 2: platform, duri, dan koin.
void bangunLevel2() {
  // Platform: x, y, lebar, tinggi (MovingPlatform = bergerak).
  platforms.add(new Platform(0, 560, 300, 100));
  platforms.add(new Platform(390, 500, 160, 25));
  platforms.add(new Platform(620, 430, 160, 25));
  platforms.add(new Platform(850, 500, 170, 25));
  platforms.add(new Platform(1100, 560, 240, 100));
  platforms.add(new Platform(1430, 480, 180, 25));
  platforms.add(new Platform(1680, 410, 170, 25));
  platforms.add(new Platform(1920, 480, 200, 25));
  platforms.add(new Platform(2200, 560, 220, 100));
  platforms.add(new Platform(2500, 490, 170, 25));
  platforms.add(new Platform(2740, 420, 180, 25));
  platforms.add(new Platform(2990, 500, 410, 100));

  // Rintangan: duri lantai (x, y, jumlah) dan stalaktit menggantung.
  tambahDuri(140, 560, 3);
  tambahDuri(1160, 560, 4);
  tambahDuri(2250, 560, 3);
  tambahDuri(3090, 500, 3);

  // Koin yang bisa dikumpulkan (+100 skor).
  tambahKoin(200, 505);
  tambahKoin(430, 455);
  tambahKoin(670, 385);
  tambahKoin(900, 455);
  tambahKoin(1200, 505);
  tambahKoin(1480, 435);
  tambahKoin(1730, 365);
  tambahKoin(1980, 435);
  tambahKoin(2290, 505);
  tambahKoin(2550, 445);
  tambahKoin(2790, 375);
  tambahKoin(3180, 445);
}
