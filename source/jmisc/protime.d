module jmisc.protime;

//version = feedBack;

import jmisc.base;
//immutable checkForZero = "if (mMinutes == 0) return 0;";

import std.stdio, std.string, std.conv;

struct ProTimeResults {
    int mMinutes;

    int totalMinutes() {
        return mMinutes;
    }

    void hoursMinutesDays(out int hours, out int minutes, out int days) {
        version(feedBack) {
            writeln("In ", __FUNCTION__);
            trace!mMinutes;
        }
        if (totalMinutes == 0)
            throw new Exception("Devide by zero");
        int h = mMinutes / 60, m = mMinutes % 60, d;
        //d = (h / 60) / 24;
        d = h / 24;
        version(feedBack)
            writeln(__FUNCTION__, ": ", h," ", m, " ", d);
        hours = h;
        minutes = m;
        days = d;
    }
}

struct JTime {
    int mHour, mMinute;

    this(string s) {
        int n;
        import std : canFind;
        if (s.length < 3 || (! s.canFind("am", "pm"))) {
            version(feedBack)
                writeln("Notice: am or pm missing! - setting to zero");
            mHour = mMinute = 0;
        } else {
            if (s[2] != ':') {
                if (s[1 .. 3].isNumeric) {
                    version(feedBack)
                        mixin(trace("s[1 .. 3]"));
                    try
                        n = s[1 .. 3].to!int;
                    catch(Exception e)
                        "Conversion error".gh;
                }
            } else {
                if (s[1 .. 2].isNumeric) {
                    version(feedBack)
                        mixin(trace("s[1]"));
                    try
                        n = s[1 .. 2].to!int; //# eg. '9'.to!int = 57
                    catch(Exception e)
                        "Conversion error".gh;
                }
            }
            mHour = n;
            version(feedBack)
                mixin(trace("mHour"));
            import std.algorithm : endsWith;
            //Convert to 24 hour clock
            if (s.endsWith("am]") && mHour == 12) {
                mHour = 0;
                version(feedBack)
                    writeln("mHour set to 0");
            } else 
                if (s.endsWith("pm]") && mHour < 12) {
                    mHour += 12;
                    version(feedBack)
                        writeln("mHour increased by 12");
                }
            version(feedBack)
                trace!s;
            s = s[s.indexOf(":") + 1 .. s.indexOf("m") - 1];

            if (s.isNumeric) {
                try
                    mMinute = s.to!int;
                catch(Exception e)
                    "Conversion failure".gh;
            }
            version(feedBack)
                mixin(trace("mHour mMinute".split));
        } // else
    }

    int getTime() {
        immutable minutes = mHour * 60 + mMinute;
        version(feedBack)
            mixin(trace("minutes"));
        return minutes;
    }
}

string processTime(string[] lines) {
	string result;

    ProTimeResults results;
	/+
	[1:00pm] -> [1:01pm]
	[2:00pm] -> [2:01pm]

	[11:59am] -> [12:00pm]
	[12:59pm] -> [1:00pm]

	[11:56am] -> [12:03pm]
	[10:03am] -> [10:06am]
	[3:02pm] -> [3:07pm]

	[12:50pm] -> [1:00pm]

	[11:59am] -> [12:01pm]
	[11:59am] -> [12:00pm]

	[12:50pm] -> [1:02pm] - getting 0 ?!

Read Heb 11 1 - 40 |> [8:46am] -> [8:58am]
Read Heb 12 1 - 29 |> [10:05am] -> [10:11am]
Read Heb 13 1 - 25 [_] [11:36am] -> [11:42am]

[9:59pm] -> [10:00pm] - (get a whopping number)
	+/
	JTime[2] jtimes;
	int num;
	auto process() {
		import std : find, indexOf, split, startsWith, endsWith, canFind;
		import std.string : isNumeric;
		for1: foreach(line; lines) {
            version(feedBack)
                writeln([line]);
			string inBrackets;
			inBrackets = line.find("[");
            version(feedBack)
                trace!inBrackets;
			if (inBrackets.length > 15) {
				while(! inBrackets[1 .. 2].isNumeric) {
					if (inBrackets.length < 16) {
						continue for1;
					}
					inBrackets = inBrackets[2 .. $].find("[");
					if (inBrackets.length < 16)
						continue for1;
                    version(feedBack)
                        trace!inBrackets;
				}
				auto first = inBrackets[0 .. inBrackets.indexOf(']') + 1];
				if (! (first.startsWith("[") && first.endsWith("]")) || ! first.canFind(":"))
					continue;
				jtimes[0] = JTime(first);
				if (jtimes[0].mHour == 0  && jtimes[0].mMinute == 0)
                    version(feedBack)
                        writeln("Left: both zero");
				auto second = inBrackets[first.length .. $].find("[");
				second = second[0 .. second.indexOf("]") + 1];
				if (! (second.startsWith("[") && second.endsWith("]")) || ! second.canFind(":"))
					continue;
				jtimes[1] = JTime(second);
				if (jtimes[1].mHour == 0  && jtimes[1].mMinute == 0)
                    version(feedBack)
                        writeln("Right: both zero");
                version(feedBack)
                    mixin(trace("first second".split));
				auto tm = jtimes[1].getTime - jtimes[0].getTime;
				if (tm < 0) {
                    version(feedBack)
                        writeln("Negetive (", tm, ")"); //#negetive problem
					tm = 0;
				}
				num += tm;
                version(feedBack)
                    writefln("Total: %s, current: %s", num, tm);
			}
		}

		return "";
	}
	result = process;
    version(feedBack)
        trace!result;
	if (! result.length) {
		import std.string : format;
        version(feedBack)
            trace!num;
        ProTimeResults presults = {num};
        int h,m,d;
        try {
            presults.hoursMinutesDays(h,m,d);
        } catch(Exception e) {
            version(feedBack)
                writeln("0 minutes");
            return "";
        }
        version(feedBack) {
            writeln("In ", __FUNCTION__);
            mixin(trace("h m d".split));
        }
		result = format("Total time: %02d:%02d (%d days)", h,m,d);
        version(feedBack)
            trace!result;
	}

	return result;
}
