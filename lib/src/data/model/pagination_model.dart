// To parse super JSON data, do
//
//     final paginationModel = paginationModelFromJson(jsonString);

import 'package:personal/src/domain/entities/pagination_entity.dart';



class PaginationModel extends PaginationEntity {


    PaginationModel({
        required super.page,
        required super.limit,
        required super.total,
        required super.totalPages,
        required super.hasNextPage,
        required super.hasPreviousPage,
    });

    factory PaginationModel.fromJson(Map<String, dynamic> json) => PaginationModel(
        page: json["page"] ??0,
        limit: json["limit"] ??0,
        total: json["total"] ??0,
        totalPages: json["totalPages"] ??0,
        hasNextPage: json["hasNextPage"]??false,
        hasPreviousPage: json["hasPreviousPage"]??false,
    );

 
}
