class BillItem {
  double cost;
  Map<String, bool>
      splitAmong; // Maps user name to whether they are involved in this item

  BillItem({
    required this.cost,
    required this.splitAmong,
  });
}
