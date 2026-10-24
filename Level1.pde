// =====================================================
// LEVEL 1 - PADANG HUJAN
//   Data level, susunan objek (platform, duri, koin), dan latar. Tema: hujan, lantai normal.
// =====================================================

// Fungsi infoLevel1: Data Level 1 Padang Hujan: nama, misi, aturan, ukuran, cuaca hujan, warna.
Level infoLevel1() {
  Level L = new Level();
  // Identitas dan teks level.
  L.id = 1;
  L.nama = "PADANG HUJAN";
  L.tujuan = "Kumpulkan koin, aktifkan checkpoint, lalu capai portal hijau di ujung padang.";
  L.tip = "Tip: lompat di ujung platform untuk jarak lompatan terjauh.";
  // Daftar aturan yang tampil di popup.
  L.aturan = new String[] {
    "Gerak: A / D atau panah. Lompat: SPASI / W / panah atas.",
    "Duri merah berbahaya! Menyentuhnya mengurangi 1 nyawa.",
    "Koin = +100 poin. Bendera checkpoint = +250 poin.",
    "Jatuh ke jurang juga mengurangi nyawa. Nyawa habis = game over."
  };
  // Ukuran dunia, posisi checkpoint dan portal.
  L.lebar = 2800;
  L.cpX = 1690;
  L.cpY = 560;
  L.exitY = 510;
  // Fisika, cuaca, dan musik.
  L.traksi = 1.0;
  L.tipeCuaca = C_HUJAN;
  L.indexBgm = 1;
  // Warna platform, cahaya, dan langit.
  L.cTanah = color(120, 80, 45);
  L.cAtas = color(55, 150, 60);
  L.cAmbient = color(120, 130, 150);
  L.cSinar = color(200, 210, 230);
  L.langitA = color(60, 75, 100);
  L.langitB = color(140, 165, 185);
  return L;
}

// Fungsi bangunLevel1: Menyusun objek Level 1: platform, duri, dan koin.
void bangunLevel1() {
  // Platform: x, y, lebar, tinggi (MovingPlatform = bergerak).
  platforms.add(new Platform(0, 560, 420, 100));
  platforms.add(new Platform(510, 560, 280, 100));
  platforms.add(new Platform(880, 500, 180, 25));
  platforms.add(new Platform(1120, 440, 190, 25));
  platforms.add(new Platform(1370, 500, 240, 25));
  platforms.add(new Platform(1690, 560, 260, 100));
  platforms.add(new Platform(2010, 500, 180, 25));
  platforms.add(new Platform(2250, 440, 200, 25));
  platforms.add(new Platform(2510, 560, 290, 100));

  // Rintangan: duri lantai (x, y, jumlah) dan stalaktit menggantung.
  tambahDuri(250, 560, 5);
  tambahDuri(610, 560, 3);
  tambahDuri(1730, 560, 3);
  tambahDuri(2590, 560, 3);

  // Koin yang bisa dikumpulkan (+100 skor).
  tambahKoin(170, 510);
  tambahKoin(335, 490);
  tambahKoin(580, 505);
  tambahKoin(720, 505);
  tambahKoin(930, 455);
  tambahKoin(1190, 395);
  tambahKoin(1450, 455);
  tambahKoin(1550, 455);
  tambahKoin(1770, 505);
  tambahKoin(1850, 505);
  tambahKoin(2070, 455);
  tambahKoin(2320, 395);
  tambahKoin(2640, 505);
}
