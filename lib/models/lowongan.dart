class Lowongan {
  final int id;
  final String namaLowongan;
  final String jenjangPendidikan;
  final String jurusanPendidikan;
  final String persyaratan;
  final String penutupan;
  final String rincian;
  final String kategori;
  final String waktuBekerja;
  final String gaji;
  final String status;

  Lowongan({
    required this.id,
    required this.namaLowongan,
    required this.jenjangPendidikan,
    required this.jurusanPendidikan,
    required this.persyaratan,
    required this.penutupan,
    required this.rincian,
    required this.kategori,
    required this.waktuBekerja,
    required this.gaji,
    required this.status,
  });

  factory Lowongan.fromJson(Map<String, dynamic> json) {
    return Lowongan(
      id: json['id'],
      namaLowongan: json['nama_lowongan'],
      jenjangPendidikan: json['jenjang_pendidikan_lowongan'],
      jurusanPendidikan: json['jurusan_pendidikan_lowongan'],
      persyaratan: json['persyaratan_lowongan'],
      penutupan: json['penutupan_lowongan'],
      rincian: json['rincian_lowongan'],
      kategori: json['kategori_lowongan'],
      waktuBekerja: json['waktu_bekerja'],
      gaji: json['gaji_perbulan'],
      status: json['status_lowongan'],
    );
  }
}
