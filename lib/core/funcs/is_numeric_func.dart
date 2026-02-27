bool isNumeric(String str) {
  try {
    int n=  int.parse(str);
    if (n<0) throw Error();
  } catch (e) {
    //print(e.toString()+'12');
    return false;
  }
  return true;
}