class DirectOrder {
  final String? id;
  final String? projectId;
  final String? categoryId;
  final List<String>? subCategoryIds;

  DirectOrder({this.id, this.projectId, this.categoryId, this.subCategoryIds});

  factory DirectOrder.fromJson(Map<String, dynamic> json) {
    final offerHistory = json['offer_history'];
    String? categoryId;
    List<String> subCategoryIds = [];

    if (offerHistory != null && offerHistory.isNotEmpty) {
      final provider = offerHistory[0]['provider_id'];
      categoryId = provider['category_id']?['_id'];
      if (provider['subcategory_ids'] != null) {
        subCategoryIds = List<String>.from(
          provider['subcategory_ids'].map((e) => e['_id'].toString()),
        );
      }
    }

    return DirectOrder(
      id: json['_id'],
      projectId: json['project_id'],
      categoryId: categoryId,
      subCategoryIds: subCategoryIds,
    );
  }
}
