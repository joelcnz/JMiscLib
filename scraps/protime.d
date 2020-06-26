module scraps.protime;

string processTime(string[] lines) {
	string result;

	struct JTime {
		int mHour, mMinute;

		this(string s) {
			writeln("this: (",s , ')');
			int n;
			import std : canFind;
			if (s.length < 3 || (! s.canFind("am", "pm"))) {
				writeln("Notice: am or pm missing! - setting to zero");
				mHour = mMinute = 0;
			} else {
				if (s[2] != ':') {
					if (s[1 .. 3].isNumeric) {
						mixin(trace("s[1 .. 3]"));
						n = s[1 .. 3].to!int;
					}
				} else {
					if (s[1 .. 2].isNumeric) {
						mixin(trace("s[1]"));
						n = s[1 .. 2].to!int; //# eg. '9'.to!int = 57
					}
				}
				mHour = n;
				mixin(trace("mHour"));
				import std.algorithm : endsWith;
				//Convert to 24 hour clock
				if (s.endsWith("am]") && mHour == 12) {
					mHour = 0;
					writeln("mHour set to 0");
				} else 
					if (s.endsWith("pm]") && mHour < 12) {
						mHour += 12;
						writeln("mHour increased by 12");
						//if (mHour == 12)
						//	mHour = 0;
					}

				trace!s;
				s = s[s.indexOf(":") + 1 .. s.indexOf("m") - 1];

				if (s.isNumeric) {
					try
						mMinute = s.to!int;
					catch(Exception e)
						writeln("Conversion failure");
				}

				mixin(trace("mHour mMinute".split));
			} // else
		}

		int getTime() {
			immutable minutes = mHour * 60 + mMinute;
			mixin(trace("minutes"));
			return minutes;
		}
	}
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
		import std : find, indexOf, split, startsWith, endsWith;
		import std.string : isNumeric;
		for1: foreach(line; lines) {
			writeln([line]);
			string inBrackets;
			inBrackets = line.find("[");
			trace!inBrackets;
			if (inBrackets.length > 15) {
				while(! inBrackets[1 .. 2].isNumeric) {
					if (inBrackets.length < 16) {
						continue for1;
					}
					inBrackets = inBrackets[2 .. $].find("[");
					if (inBrackets.length < 16)
						continue for1;
					trace!inBrackets;
				}
				auto first = inBrackets[0 .. inBrackets.indexOf(']') + 1];
				if (! (first.startsWith("[") && first.endsWith("]")))
					continue;
				jtimes[0] = JTime(first);
				if (jtimes[0].mHour == 0  && jtimes[0].mMinute == 0)
					writeln("Left: both zero");
				auto second = inBrackets[first.length .. $].find("[");
				second = second[0 .. second.indexOf("]") + 1];
				if (! (second.startsWith("[") && second.endsWith("]")))
					continue;
				jtimes[1] = JTime(second);
				if (jtimes[1].mHour == 0  && jtimes[1].mMinute == 0)
					writeln("Right: both zero");
				mixin(trace("first second".split));
				auto tm = jtimes[1].getTime - jtimes[0].getTime;
				if (tm < 0) {
					writeln("Negetive (", tm, ")"); //#negetive problem
					tm = 0;
				}
				num += tm;
				writefln("Total: %s, current: %s", num, tm);
			}
		}

		return "";
	}
	result = process;
	trace!result;
	if (! result.length) {
		import std.string : format;
		result = format("Total time: %02d:%02d (%d days)", num / 60, num % 60, (num / 60) / 24);
	}

	return result;
}
