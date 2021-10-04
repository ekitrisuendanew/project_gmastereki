class CatatanModel {
  final String id;
  final String gambar;
  final String judul;
  final String deskripsi;
  final String link;
  final String created_ad;

  CatatanModel({
    required this.id,
    required this.gambar,
    required this.judul,
    required this.deskripsi,
    required this.link,
    required this.created_ad,
  });

  factory CatatanModel.fromJson(Map<dynamic, dynamic> json) {
    return CatatanModel(
      id: json['id'],
      gambar: json['gambar'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      link: json['link'],
      created_ad: json['created_ad'],
    );
  }
}