import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart' show Response;
import 'package:flutter/material.dart';
import 'package:stock/stock.dart';

import 'package:waterflyiii/generated/swagger_fireflyiii_api/firefly_iii.enums.swagger.dart'
    as enums show TransactionTypeFilter;
import 'package:waterflyiii/generated/swagger_fireflyiii_api/firefly_iii.swagger.dart';

/*Future<TransactionArray> stockTransactionsGet({ String? xTraceId,
    int? page,
    String? start,
    String? end,
    enums.TransactionTypeFilter? type,}) {
      return Fetcher.ofFuture<String, TransactionArray>(
    (userId) => api.v1TransactionsGet(xTraceId: xTraceId, page: page, start: start, end: end, type: type),
  );
    }*/

/*class STransactionSoT extends CachedSourceOfTruth<String, TransactionRead> {
  STransactionSoT();
}*/

/*class DebugSoT extends CachedSourceOfTruth<String, List<String>> {
  DebugSoT();

  @override
  @protected
  Stream<List<String>?> reader(String key) async* {
    debugPrint("reading $key");
    yield* super.reader(key);
  }

  @override
  @protected
  Future<void> write(String key, List<String>? value) async {
    debugPrint("writing $key: ${value?.length ?? 0}");
    await super.write(key, value);
  }
}*/

class TransStock {
  final FireflyIii api;

  late Stock<String, TransactionRead> _singleStock;
  Stock<String, TransactionRead> get singleStock => _singleStock;

  late Stock<String, List<String>> _getStock;
  late Stock<String, List<String>> _getAccountStock;
  late Stock<String, List<String>> _getSearchStock;

  final CachedSourceOfTruth<String, TransactionRead> _singleSoT =
      CachedSourceOfTruth<String, TransactionRead>();
  final CachedSourceOfTruth<String, List<String>> _listSoT =
      CachedSourceOfTruth<String, List<String>>();

  TransStock(this.api) {
    _singleStock = Stock<String, TransactionRead>(
      fetcher: Fetcher.ofFuture<String, TransactionRead>(
        (String id) => api
            .v1TransactionsIdGet(id: id)
            .then((Response<TransactionSingle> value) => value.body!.data),
      ),
      sourceOfTruth: _singleSoT,
    );
    _getStock = Stock<String, List<String>>(
      fetcher: Fetcher.ofFuture<String, List<String>>(
        (String id) {
          final _getOptions query = _getOptions.fromJson(jsonDecode(id));
          return api
              .v1TransactionsGet(
            xTraceId: query.xTraceId,
            page: query.page,
            start: query.start,
            end: query.end,
            type: query.type,
          )
              .then<List<String>>((Response<TransactionArray> value) {
            for (TransactionRead element in value.body!.data) {
              _singleSoT.write(element.id, element);
            }
            return value.body!.data.map((TransactionRead e) => e.id).toList();
          });
        },
      ),
      sourceOfTruth: _listSoT,
    );
    _getAccountStock = Stock<String, List<String>>(
      fetcher: Fetcher.ofFuture<String, List<String>>(
        (String id) {
          final _getOptions query = _getOptions.fromJson(jsonDecode(id));
          return api
              .v1AccountsIdTransactionsGet(
            xTraceId: query.xTraceId,
            id: query.id,
            page: query.page,
            limit: query.limit,
            start: query.start,
            end: query.end,
            type: query.type,
          )
              .then<List<String>>((Response<TransactionArray> value) {
            for (TransactionRead element in value.body!.data) {
              _singleSoT.write(element.id, element);
            }
            return value.body!.data.map((TransactionRead e) => e.id).toList();
          });
        },
      ),
      sourceOfTruth: _listSoT,
    );
    _getSearchStock = Stock<String, List<String>>(
      fetcher: Fetcher.ofFuture<String, List<String>>(
        (String id) {
          final _getOptions query = _getOptions.fromJson(jsonDecode(id));
          return api
              .v1SearchTransactionsGet(
            xTraceId: query.xTraceId,
            query: query.query,
            page: query.page,
          )
              .then<List<String>>((Response<TransactionArray> value) {
            for (TransactionRead element in value.body!.data) {
              _singleSoT.write(element.id, element);
            }
            return value.body!.data.map((TransactionRead e) => e.id).toList();
          });
        },
      ),
      sourceOfTruth: _listSoT,
    );
  }

  Future<List<TransactionRead>> get({
    String? xTraceId,
    int? page,
    String? start,
    String? end,
    enums.TransactionTypeFilter? type,
  }) async {
    return _getStock
        .get(jsonEncode(_getOptions(
      xTraceId: xTraceId,
      page: page,
      start: start,
      end: end,
      type: type,
    )))
        .then(
      (List<String> list) async {
        List<TransactionRead> result = <TransactionRead>[];
        for (String element in list) {
          result.add(await _singleStock.get(element));
        }
        return result;
      },
    );
  }

  Future<List<TransactionRead>> getAccount({
    String? xTraceId,
    required String id,
    int? page,
    int? limit,
    String? start,
    String? end,
    enums.TransactionTypeFilter? type,
  }) async {
    return _getAccountStock
        .get(jsonEncode(_getOptions(
      xTraceId: xTraceId,
      id: id,
      page: page,
      limit: limit,
      start: start,
      end: end,
      type: type,
    )))
        .then(
      (List<String> list) async {
        List<TransactionRead> result = <TransactionRead>[];
        for (String element in list) {
          result.add(await _singleStock.get(element));
        }
        return result;
      },
    );
  }

  Future<List<TransactionRead>> getSearch({
    String? xTraceId,
    required String? query,
    int? page,
  }) async {
    return _getSearchStock
        .get(jsonEncode(_getOptions(
      xTraceId: xTraceId,
      query: query,
      page: page,
    )))
        .then(
      (List<String> list) async {
        List<TransactionRead> result = <TransactionRead>[];
        for (String element in list) {
          result.add(await _singleStock.get(element));
        }
        return result;
      },
    );
  }

  void clear() {
    _getStock.clearAll();
    _getAccountStock.clearAll();
    _getSearchStock.clearAll();
  }
}

// ignore: camel_case_types
class _getOptions {
  final String? xTraceId;
  final int? page;
  final String? start;
  final String? end;
  final enums.TransactionTypeFilter? type;
  // exclusive for getAccount
  final String? id;
  final int? limit;
  // exlusive for getSearch
  final String? query;

  _getOptions({
    this.xTraceId,
    this.page,
    this.start,
    this.end,
    this.type,
    this.id,
    this.limit,
    this.query,
  });

  _getOptions.fromJson(Map<String, dynamic> json)
      : xTraceId = json['xTraceId'],
        page = json['page'],
        start = json['start'],
        end = json['end'],
        type = json['type'],
        id = json['id'],
        limit = json['limit'],
        query = json['query'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'xTraceId': xTraceId,
        'page': page,
        'start': start,
        'end': end,
        'type': type,
        'id': id,
        'limit': limit,
        'query': query,
      };
}
