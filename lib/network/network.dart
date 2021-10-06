class NetworkUrl {

  static String url = "https://ekitrisuenda.com/project_gmastereki/users_gmastereki";


  static String addNote() {
    return "$url/AddNote.php";
  }

  static String getNote(String idUser) {
    return "$url/GetNote.php?idUser=$idUser";
  }

  static String editNote() {
    return "$url/EditNote.php";
  }

  static String deleteNote() {
    return "$url/DeleteNote.php";
  }



}