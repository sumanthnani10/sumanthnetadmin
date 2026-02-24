import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCollection<T> {
  String collectionName;
  List<T> list = [];
  Map<String, T> map = {};
  CollectionReference ref;
  FirebaseFirestore fireInst = FirebaseFirestore.instance;

  getCollection() async {
    list = [];
    map.clear();
    await ref.get().then((value) {
      value.docs.sort((a, b) => a.get("title").compareTo(b.get("title")));
      value.docs.forEach((element) {
        list.add(element.data());
        map[element.get("name")] = list.last;
      });
    });
  }

  upsert(data, [bool reload = true, bool edit = false, String matchValue, String matchKey = "name"]) async {
    var l;
    if (matchKey == "name") {
      matchValue = data.name;
      l = await ref.where("$matchKey", isEqualTo: "${data.name}").get();
    } else {
      l = await ref.where("$matchKey", isEqualTo: "${matchValue ?? "~"}").get();
    }
    if (edit || l.docs.length == 0) {
      if (l.docs.length > 0 && l.docs.first.id != data.id) {
        print("Edit Error: ID Mismatch");
        return "Edit Error: ID Mismatch";
      }
      await ref.doc(data.id).set(data);
      if(reload)
      await getCollection();
      return null;
    } else {
      print("${collectionName.toUpperCase()} Already Exists with $matchValue.");
      return "${collectionName.toUpperCase()} Already Exists with $matchValue.";
    }
  }

  delete(data) async {
    await ref.doc(data.id).delete();
    await getCollection();
    return null;
  }

}