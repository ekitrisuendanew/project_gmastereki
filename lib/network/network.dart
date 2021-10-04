class NetworkUrl {

  static String url = "https://ekitrisuenda.com/project_gmastereki/users_gmastereki";

  static String getCatatan(String idUser) {
    return "$url/GetCatatan.php?idUser=$idUser";
  }

  static String deleteCatatan() {
    return "$url/DeleteCatatan.php";
  }

  static String addCatatan() {
    return "$url/AddCatatan.php";
  }

}