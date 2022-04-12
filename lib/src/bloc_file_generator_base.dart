// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
// class Awesome {
//   bool get isAwesome => true;
//
// }
import 'dart:io';

class BlocFileGenerator {
  String? capitalize(String? name) {
    return "${name?[0].toUpperCase()}${name?.substring(1).toLowerCase()}";
  }

  void createBloc(String? label) {
    String? name = capitalize(label);

    String blocCode = """
class ${name}Bloc{
  ${name}Bloc();
}
  """;

    File('lib/$label/bloc/${label}_bloc.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(blocCode);
    });
  }

  void createEntityModel(String? label) {
    String? name = capitalize(label);

    String entityModel = """
class ${name}GraphQlEntity{

  ${name}GraphQlEntity.fromJson(dynamic json) {
  
  }
}
  """;

    File('lib/$label/model/entity/${label}_graphql_entity.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(entityModel);
    });
  }

  void createRequestModel(String? label) {
    String? name = capitalize(label);

    String getRequestModel = """
class Get${name}sRequest {
  int page;
  Get${name}sRequest({required this.page,});

  /// Indicates if this request is for the initial/first data
  bool get isInitialRequest => page == 1;
}

  """;

    File('lib/$label/model/request/get_${label}s_request.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(getRequestModel);
    });
  }

  void createResponseModel(String? label) {
    String? name = capitalize(label);

    String responseModel = """
import '../entity/${label}_graphql_entity.dart';

class Get${name}sGraphQlResponse {
  List<${name}GraphQlEntity>? ${label}s;
  int? page;
  late bool hasMoreData;
  int? totalCount;

  Get${name}sGraphQlResponse.fromJson(Map<String, dynamic> map,
      {int? page}) {
    ${label}s = [];
    hasMoreData = true;
    final ${label}sJson = map['${label}s'];
    if (${label}sJson != null && ${label}sJson is Map) {
      final itemJson = ${label}sJson['data'];
      if (itemJson != null && itemJson is List) {
        ${label}s!.addAll(
            itemJson.map((e) => ${name}GraphQlEntity.fromJson(e)).toList());
      }
      final paginationJson = ${label}sJson['pagination'];
      if (paginationJson != null)
        hasMoreData = paginationJson['hasMorePages'] ?? true;
      totalCount = paginationJson['total'];
    }
    this.page = page;
  }
} 
  """;

    File('lib/$label/model/response/get_${label}s_graphql_response.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(responseModel);
      // Stuff to do after file has been created...
    });
  }

  void createModel(String? label) {
    String? name = capitalize(label);

    createEntityModel(label);
    createRequestModel(label);
    createResponseModel(label);

    String modelCode = """
class $name{
  $name();
}
  """;

    File('lib/$label/model/$label.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(modelCode);
      // Stuff to do after file has been created...
    });

    String modelDataCode = """
import '$label.dart';
    
class ${name}sData{
  List<$name>? ${label}s;
  bool isEndReached;
  int? currentPage;
  int? totalCount;

  ${name}sData(
      {this.${label}s,
      this.isEndReached = false,
      this.currentPage,
      this.totalCount,});
      
  ${name}sData copyWith(
      {List<$name>? ${label}s,
      bool? isEndReached,
      int? currentPage,
      int? totalCount,}) {
    return ${name}sData(
      ${label}s: ${label}s ?? this.${label}s,
      isEndReached: isEndReached ?? this.isEndReached,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
  
  /// Check if this data is of first request
  bool get isInitialData => currentPage == 1;
}
  """;

    File('lib/$label/model/${label}s_data.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(modelDataCode);
      // Stuff to do after file has been created...
    });
  }

  void createMappers(String? label) {
    String? name = capitalize(label);

    String entityMapper = """
import '../model/$label.dart';
import '../model/entity/${label}_graphql_entity.dart';

import '../../../base/base_mapper.dart';

class ${name}GraphQlEntityMapper
    extends BaseMapper<${name}GraphQlEntity, $name> {
  @override
  $name map(${name}GraphQlEntity t) {
    return $name();
  }
}
    """;

    File('lib/$label/mapper/${label}_graphql_entity_mapper.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(entityMapper);
    });

    String responseMapper = """
import '../../../base/base_mapper.dart';
import '${label}_graphql_entity_mapper.dart';
import '../model/${label}s_data.dart';
import '../model/response/get_${label}s_graphql_response.dart';

class ${name}GraphQlResponseMapper
    extends BaseMapper<Get${name}sGraphQlResponse, ${name}sData> {
  final _${label}sGraphQlEntityMapper = ${name}GraphQlEntityMapper();

  @override
  ${name}sData map(Get${name}sGraphQlResponse t) {
    return ${name}sData(
      isEndReached: !t.hasMoreData,
      currentPage: t.page,
      ${label}s:
          t.${label}s?.map((e) => _${label}sGraphQlEntityMapper.map(e)).toList() ??
              [],
    );
  }
}
    """;

    File('lib/$label/mapper/${label}_graphql_response_mapper.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(responseMapper);
    });
  }

  void createSource(String? label) {
    String? name = capitalize(label);

    String request = """
class ${name}GraphQlRequest{

}
    """;

    String source = """
class ${name}GraphQlSource{
  ${name}GraphQlSource();
}
  """;

    File('lib/$name/source/${name}_graphql_request.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(request);
    });

    File('lib/$label/source/${label}_graphql_source.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(source);
    });
  }

  void createState(String? label) {
    String? name = capitalize(label);

    String getState = """
import '../../base/base_ui_state.dart';
import '../model/${label}s_data.dart';

class Get${name}sState extends BaseUiState<${name}sData> {
  bool? isInitialRequest;

  Get${name}sState.loading({
    this.isInitialRequest,
  }) : super.loading();

  Get${name}sState.completed(
    ${name}sData? data, {
    this.isInitialRequest,
  }) : super.completed(data: data);

  Get${name}sState.error(
    dynamic error, {
    this.isInitialRequest,
  }) : super.error(error);
}
  """;

    File('lib/$label/state/get_${label}_state.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(getState);
      // Stuff to do after file has been created...
    });

    String uiStateManager = """
import '../repo/${label}_repo.dart';
    
class ${name}UiStateManager{
  final ${name}Repo _${label}Repo;
  ${name}UiStateManager(this._${label}Repo);
}
    """;

    File('lib/$label/state/${label}_ui_state_manager.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(uiStateManager);
      // Stuff to do after file has been created...
    });
  }

  void createRepo(String? label) {
    String? name = capitalize(label);

    String repo = """
class ${name}Repo{
  ${name}Repo();
}
    """;

    File('lib/$label/repo/${label}_repo.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(repo);
      // Stuff to do after file has been created...
    });
  }

  void createModule(String? label) {
    String? name = capitalize(label);

    String module = """
class ${name}Module{
  static ${name}Module _instance = ${name}Module._internal();

  ${name}Module._internal();

  factory ${name}Module() {
    return _instance;
  }
}
    """;

    File('lib/$label/di/${label}_module.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(module);
      // Stuff to do after file has been created...
    });
  }

  void createUi(String? label) {
    String? name = capitalize(label);

    String mainPage = """
import 'package:flutter/material.dart';

class ${name}Page extends StatefulWidget {
  const ${name}Page({Key? key}) : super(key: key);

  @override
  _${name}PageState createState() => _${name}PageState();
}

class _${name}PageState extends State<${name}Page> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

    """;

    File('lib/$label/ui/${label}_page.dart')
        .create(recursive: true)
        .then((File file) async {
      file.writeAsString(mainPage);
    });
  }

  void createFiles() {
    print("Enter bloc name: ");
    String? name = stdin.readLineSync();
    print("Creating bloc module $name");

    createBloc(name);
    createModel(name);
    createMappers(name);
    createSource(name);
    createState(name);
    createRepo(name);
    createModule(name);
    createUi(name);
  }
}