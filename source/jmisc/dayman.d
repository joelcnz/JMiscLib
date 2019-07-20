module jmisc.dayman;

import jmisc.day;

struct DayMan {
	Day[] _days;
	
	this(in string notes) {
		import std.string: lineSplitter, join;
		import std.array: array;
		import std.stdio: writeln;
		import std.algorithm: endsWith;
		import std.array: replicate;
		import std.range: retro;
		
		string[] lines = notes.lineSplitter.array;

		for(int i; i < lines.length; i += 1) {
			if (lines[i].endsWith(` \#/`)) {
				lines = lines[i .. $];
				i = 0;
				do {
					i += 1;
					if (i == lines.length || lines[i].endsWith(` \#/`)) {
						i -= 1;
						while(lines[i].length == 0)
							i -= 1;
						_days ~= Day(lines[0 .. i + 1].join("\n") ~ "\n".replicate(2));
						break;
					}
				} while(i < lines.length);
			}
		}
		_days = _days.retro.array;
	}

	auto toString() const {
		import std.conv: to;

		string result;

		foreach(day; _days) {
			result ~= day.to!string ~ "\n";
		}

		return result;
	}
	
	auto collectAllFromTitle(in string title) {
		string result;
		
		import std.stdio: writeln;

		foreach(day; _days) with (day) {
			auto txt = getNotesFromTitle(title);
			
			if (_containsTitle) {
				result ~=
					_date ~ "\n" ~
					"\n" ~
					txt;
			}
		}
		
		return result;
	}

	auto collectAllFromTitleAndSubTitle(in string title, in string subTitle) {
		string result;
		
		import std.stdio: writeln;

		foreach(day; _days) with (day) {
			auto txt = notesFromSubTitle(title, subTitle);
			
			if (_containsTitle && _containsSubTitle) {
				result ~=
					_date ~ "\n" ~
					"\n" ~
					txt;
			}
		}
		
		return result;
	}
}
