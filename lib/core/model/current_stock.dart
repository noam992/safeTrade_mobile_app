
class CurrentStock {
  GlobalQuote? globalQuote;

  CurrentStock({this.globalQuote});

  CurrentStock.fromJson(Map<String, dynamic> json) {
    globalQuote = json['Global Quote'] != null
        ? GlobalQuote.fromJson(json['Global Quote'])
        : null;
  }

}

class GlobalQuote {
  String? s01Symbol;
  String? s02Open;
  String? s03High;
  String? s04Low;
  String? s05Price;
  String? s06Volume;
  String? s07LatestTradingDay;
  String? s08PreviousClose;
  String? s09Change;
  String? s10ChangePercent;

  GlobalQuote(
      {this.s01Symbol,
        this.s02Open,
        this.s03High,
        this.s04Low,
        this.s05Price,
        this.s06Volume,
        this.s07LatestTradingDay,
        this.s08PreviousClose,
        this.s09Change,
        this.s10ChangePercent});

  GlobalQuote.fromJson(Map<String, dynamic> json) {
    s01Symbol = json['01. symbol'];
    s02Open = json['02. open'];
    s03High = json['03. high'];
    s04Low = json['04. low'];
    s05Price = json['05. price'];
    s06Volume = json['06. volume'];
    s07LatestTradingDay = json['07. latest trading day'];
    s08PreviousClose = json['08. previous close'];
    s09Change = json['09. change'];
    s10ChangePercent = json['10. change percent'];
  }

}
