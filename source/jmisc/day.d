//#need better end of line search
//# || if just white space
module jmisc.day;

/// Notes day
struct Day {
	/// Which day
	string _date;
	/// Whole day
	string _day;
	
	//MainTitle _mainTitle;

	bool _containsTitle,
		_containsSubTitle;
	
	this(in string txt) {
		import std.string: indexOf;

		_date = txt[0 .. txt.indexOf("\n")]; //#need better end of line search
		_day = txt;
	}

	/// get day as a string
	auto toString() const {
		return _day;
	}
	
	/// 2. Seperate days with bodys to string
	/// @return a string with title with body
	auto getNotesFromTitle(in string title) {
		string result;
		
		import std.array : array;
		import std.stdio : writeln;
        import std.string : indexOf, join, lineSplitter;
		
		string[] lines;
		
		lines = _day.lineSplitter.array;
		
		_containsTitle = false;
		for1: for(size_t i; i < lines.length; i += 1) {
			import std.algorithm: endsWith;
            import std.array: replicate;

			if (lines[i] == title) {
				_containsTitle = true;
				result = title ~ "\n";
				lines = lines[i + 1 .. $];
				i = 0;
				do {
					i += 1;
					if (i == lines.length || lines[i].endsWith(` \#/`, ` \/`)) {
						i -= 1;
						while(lines[i].length == 0 && i > 0) //# || if just white space
							i -= 1;
						result ~= lines[0 .. i + 1].join("\n") ~ "\n".replicate(3);
						break for1;
					}
				} while(i < lines.length);
			}
		}

		return result;
	}

	auto notesFromSubTitle(in string title, in string subTitle) {
		string result;
		
		import std.array : array;
		import std.stdio : writeln;
        import std.string : indexOf, join, lineSplitter;
		
		string[] lines;
		
		lines = getNotesFromTitle(title).lineSplitter.array;
		
		_containsTitle = _containsSubTitle = false;
		for1: for(size_t i; i < lines.length; i += 1) {
			import std.algorithm : endsWith;
            import std.array : replicate;

			if (lines[i] == title) {
				_containsTitle = true;
				result = title ~ "\n\n";

				lines = lines[i + 1 .. $];

				// search for sub title
				do {
					if (lines[i] == subTitle) {
						_containsSubTitle = true;
						lines = lines[i .. $];
						break;
					}
					i += 1;
				} while(i < lines.length);

				if (! _containsSubTitle)
					break;

				// find end, back back, select
				i = 0;
				do {
					i += 1;
					if (i == lines.length || lines[i].endsWith(` \#/`, ` \/`, ` \/b`)) {
						i -= 1;
						while(lines[i].length == 0 && i > 0) //# || if just white space
							i -= 1;
						result ~= lines[0 .. i + 1].join("\n") ~ "\n".replicate(3);
						break for1;
					}
				} while(i < lines.length);
			}
		}

		return result;
	}

	unittest {
		auto day = Day(`11 2 2018 \#/
		
Test \/

This is a test

Test Sub \/b

Sub body


Test2 \/

This is a test as well!`);

		assert(day.getNotesFromTitle(`Test \/`) == `Test \/

This is a test

Test Sub \/b

Sub body


`);

		assert(day.getNotesFromTitle(`Test2 \/`) == `Test2 \/

This is a test as well!


`);

/+
		auto notesFromTitle = day.getNotesFromTitle(`Test \/`);
		assert(notesFromTitle.notesFromSubTitle(`Test Sub \/b`) == `Test Sub \/b

Sub body


`);
+/
	}
}
