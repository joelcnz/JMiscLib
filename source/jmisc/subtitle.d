module jmisc.subtitle;
/+
struct SubTitle {
    string _date;
    string _title;
    string _subTitle;
    string _sbody;

    this(in string date, in string title, in string sbody) {
        _date = date;
        _title = title;
        _subTitle = _subTitle;
        _sbody = sbody;
    }

    auto toString() {
        return _date ~ " \#/\n\n" ~
               _title ~ "\n\n" ~
               _sbody ~ "\n\n\n";
    }
}
+/