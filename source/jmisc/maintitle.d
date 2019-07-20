module jmisc.maintitle;
/+
struct MainTitle {
    string _date;
    string _title;
    string _sbody;

    this(in string date, in string title, in string sbody) {
        _date = date;
        _title = title;
        _sbody = sbody;
    }



    auto toString() {
        return _date ~ " \#/\n\n" ~ _title ~ "\n" ~ _sbody ~ "\n\n\n";
    }
}
+/