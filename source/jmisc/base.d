//#?
//#not sure about avoiding having a gap if there's no args
module jmisc.base;


//version = CanIncludeUnittests;

version = Mine;

import std.traits;

bool g_checkPoints = true;

// see small/backups.d and folder small/BackUpSaves
void backUp(in string startFileName) {
	import std.file: exists;
	import std.path: buildPath, stripExtension; //, getExtension;
	import std.conv: to;
	import std.string: format, lastIndexOf;

	int id;
	immutable totalNFSaves = 10;
	string makeFn(in int sp) {
		return buildPath("BackUpSaves",
					format("%s_%02d%s",
						startFileName.stripExtension,
						sp,
						//startFileName.getExtension));
						startFileName[startFileName.lastIndexOf(".") .. $]));
	}
	int antifreeze = totalNFSaves;
	string backUpFileName;
	do {
		backUpFileName = makeFn(id);
		id += 1;
		antifreeze -= 1;
	} while(exists(backUpFileName) && antifreeze > -1);
	if (antifreeze == -1) {
		writeln("Notice: infinite loop detected - extra save (", backUpFileName, ")");
	}
	import std.file : copy, remove, exists;
	copy(startFileName, backUpFileName);
	string fn;
	if (id < totalNFSaves)
		fn = makeFn(id);
	else
		fn = makeFn(0);
	if (fn.exists)
		remove(fn);
	writeln("Copied '", startFileName, "' to '", backUpFileName, "'");
}

string addCommas(T)(in T num) {
	version(Mine) {
		import std.range : retro;
		import std.conv : to;

		string result,
			s = num.to!string;
		int i = cast(int)s.length - 1, t;
		while(i >= 0) {
			if (s[i] != '-' && t == 3) {
				t = 0;
				result ~= ",";
			}
			result ~= s[i];
			i -= 1;
			t += 1;
		}
		import std.algorithm;

		return result.retro.to!string;
	} else {
		//https://dlang.org/changelog/2.082.0.html#std-algorithm-iteration-joiner
	import std.algorithm.comparison : equal;
	import std.algorithm : map, joiner;
	import std.range : chain, cycle, iota, only, retro, take, zip;
	import std.format : format;
	import std.conv: to;

	auto number = num.to!string;
	static immutable delimiter = ",";

		return number.retro
		.zip(3.iota.cycle.take(number.length))
		.map!(z => chain(z[0].only, z[1] == 2 ? delimiter : null))
		.joiner
		.retro
		.to!string; // "12,345,678"
	}
}

@("Printed Numbers test")
unittest {
	writeln("One million: ", addCommas(1_000_000));
	writeln("Negative a thousand: ", addCommas(-1_000));
	writeln("One million and one millionth: ", addCommas(1_000_000.000_000_1));
}

auto getNotesSortDays(in string txt) {
	import jmisc.dayman, jmisc.day;

	// and puts them in chronological order too
	auto days = DayMan(txt);

	return days;
}

auto getNotesSortDaysToText(in string txt) {
	import std.conv: to;

	return getNotesSortDays(txt).to!string;
}

// Notes sort 12 3 2017
auto getNotesSortFromTitle(string title, in string txt) {
	import std.algorithm: canFind;

	auto days = getNotesSortDays(txt);

	if (! title.canFind(` \/`))
		title ~= ` \/`;
	string result = days.collectAllFromTitle(title);

	return result;
}

// Notes sub sort 17 4 2019
auto getNotesSortFromTitleAndSubTitle(in string title, in string subTitle, in string txt) {
	auto days = getNotesSortDays(txt);

	string result = days.collectAllFromTitleAndSubTitle(title, subTitle);

	return result;
}

//auto getNotesSortFromTitle

/++
A log: Outputs to terminal, and history.txt file
Use: use it like writeln e.g. upDateStatus(1, "two", 3.0); -> Sunday 14 January 2018 [ 7:58:34am] 1two3
+/
auto upDateStatus(T...)(T args) {
    import std.stdio : write, stdout;
	import std.conv : text;

	string txtln,
		ustxt = text(args);
	txtln = dateTimeString;
	//#not sure about avoiding having a gap if there's no args
	if (ustxt != "")
		txtln ~= " " ~ ustxt;
	txtln ~= "\n";
	write(txtln);
	stdout.flush;

	import std.file : append;
	append("history.txt", txtln);
	
	return txtln;
}

void upDateStatus() {
	"".upDateStatus;
}

/**
Prints date and time
*/
auto dateTimeString() {
	import std.string : format, split;
	import std.datetime : DateTime, Clock;
	
	auto dateNTime = cast(DateTime)Clock.currTime();
	with(dateNTime) {
		return format(
			"%s " ~ // day of the week (eg. 'Saturday')
			"%s %s %s " ~ // day, month, year
			"%s",
//			"[%s%s:%02s:%02s%s]", // hour:minute:second am/pm //#thinking of having a space if the time is 1-9
			"Sunday Monday Tuesday Wednesday Thursday Friday Saturday".split[dayOfWeek],
			day, "Zeroth January February March April May June July August September October November December".
					split[cast(int)month], year,
			timeString);
//			(hour == 0 || hour == 22 || hour == 23 || (hour >= 10 && hour <= 12) ? "" : " "),
//			(hour == 0 || hour == 12 ? 12 : hour % 12), minute, second, (hour <= 11 ? "am" : "pm"));
	}
}

string timeString() {
	import std.datetime : DateTime, Clock;

	auto dateTime = cast(DateTime)Clock.currTime();

	return timeString(dateTime, true);
}

import std.datetime : DateTime;

string timeString(DateTime time, bool includeSecond = false) {
	import std.string : format;
	import std.datetime : DateTime, Clock;

//	auto dateNTime = cast(DateTime)Clock.currTime();
	with(time) {
		return format("[%s%s:%02s:%02s%s]",
			(hour == 0 || hour == 22 || hour == 23 || (hour >= 10 && hour <= 12) ? "" : " "),
				(hour == 0 || hour == 12 ? 12 : hour % 12), minute, second, (hour <= 11 ? "am" : "pm"));
	}
}

import std.traits;

void numCycle(T)(ref T num, size_t max, T start = 0) 
	if (isNumeric!T) 
{
	num += 1;
	if (num == max + 1)
		num = start;
}

/++

+/
auto jinsert(R)(R range, string message) {
	import std.stdio : writeln;

	writeln(message);

	return range;
}

import std.stdio : writeln;
//alias gh = writeln;

// g and h beside each other (and in the middle) on the keyboard
/// Got Here!
void gh(string message = "Got here!", string fileStr = __FILE__, string functionStr = __FUNCTION__, size_t lineNum = __LINE__) {
	if (g_checkPoints)
		writeln("File: ", fileStr, ", Function: ", functionStr, ", (", lineNum, "), Message: ", message);
}

//#debug = 3;
void gh(int num, string message = "", string fileStr = __FILE__, string functionStr = __FUNCTION__,
	size_t lineNum = __LINE__) {
	if (g_checkPoints)
		writeln("Got here, point (", num, "), File: ", fileStr, ", Function: ", functionStr, ", (", lineNum, ")",
			(message != "" ? ", Message: " : ""), message);
}

/++
	Joel view for making a list string
+/
auto jview(R)(R range, in string message = "", in string bullet = ". ") {
	string result;

	import std.stdio : writeln;
	import std.conv : text;
	import std.range : enumerate;

	result = message ~ '\n';
	foreach(i, e; range.enumerate)
		result ~= text(i, bullet, e) ~ '\n';
	
	return result;
}

/// Save writing the symbol twice each time
/// ---
/// int year = 1979, day = 30;
/// mixin( trace( "year", "day" ) );
/// Output:
/// year: 1979
/// day: 30
/// ---
string traceList(in string[] strs...) {
	string result;
	foreach( str; strs )
		result ~= `import sgd.stdio : writeln; writeln( "` ~ str ~ `: ", ` ~ str ~ ` );` ~ "\n";

	return result;
}

/**
 * int a = 1;
 * double b = 0.2;
 * string c = "three";
 * 
 * eg. mixin( traceLine( "a b c".split ) );
 * 
 * Output:
 * 
 * (a: 1) (b: 0.2) (c: three)
 */
string trace(in string[] strs...) {
	string result;

	foreach( str; strs ) {
		result ~= `import std.stdio : writef, writeln; writef( "(` ~ str ~ `: %s) ", ` ~ str ~ ` );`;
	}
	result ~= `writeln();`;

	return result;
}

/++
https://github.com/Abscissa/scriptlike/blob/master/src/scriptlike/core.d
Debugging aid: Output variable name/value and file/line info to stderr.
Also flushes stderr to ensure buffering and a subsequent crash don't
cause the message to get lost.
Example:
--------
auto x = 5;
auto str = "Hello";
// Output example:
// src/myproj/myfile.d(42): x: 5
// src/myproj/myfile.d(43): str: Hello
trace!x;
trace!str;
--------
+/
template trace(alias var)
{
	void trace(string file = __FILE__, size_t line = __LINE__)()
	{
		import std.stdio : stderr;
		stderr.writeln(file, "(", line, "): ", var.stringof, ": ", var);
		stderr.flush();
	}
}

unittest {
	int x = 5;
	trace!x;
}

/**
 * Both, display code and execute
 */
string jecho(in string str) {
	import std.stdio;
	return `writeln("` ~ str ~ `"); ` ~ // display command
			str; // do the command
}

/// TDD - test driven development tool - bit of one
string test(in string exp, in string should)
{
	import std.stdio : write, writeln;
	// Note no new lines
	debug (TDD)
		return "import std.stdio : write, writeln; " ~
			"write(`" ~ should ~ " - Testing ( " ~ exp ~ " ) - `); " ~
			"if ( " ~ exp ~ " ) " ~
			"{" ~
			"	write(`PASS`); " ~
			"} " ~
			"else " ~
			"{ " ~
			"	write(`FAIL`); " ~
			"} " ~
			"writeln(` - function: `, __FUNCTION__, ` line: `, __LINE__, ` file: `, __FILE__); ";
	else
		return "";
}

unittest {
	mixin(test("1 == 1", "is one actually equal to one"));
	string s = string.init;
	mixin(test("s is null", "string is null"));
}

alias Point  = PointVec!(2, float); // default
alias Pointi = PointVec!(2, int);
alias Pointt = PointVec!(2, size_t);

struct PointVec(int D, T) if (isNumeric!T) {
private:
	T[D] v;
	alias Pt = PointVec!(D, T);
public:
	this(in T[D] v0...) {
		assert(v0.length == D);
		v[] = v0[];
	}
	
	/// eg. p1 = p2;
	auto opAssign(in Pt o) {
		assert(o.v.length == D);
		
		return v = o.v;
	}

	enum opsList = `op == "+" || op == "-" || op == "*" || op == "/"`;

	/// eg. return p1 + p2;
	auto opBinary(string op)(Pt o) if (mixin(opsList)) {
		assert(o.v.length == v.length);
		auto a = this;
		// eg. a.v[] += o.v[];
		mixin("a.v[] " ~ op ~ "= o.v[];"); // may not be the fastest in this situation
		
		return a;
	}
	
	// eg. dir + 2;
	auto opBinary(string op)(T num) if (mixin(opsList)) {
		auto a = this;
		
		mixin("a.v[] " ~ op ~ "= num;");
		
		return a;
	}
	
	// eg. 2 + dir;
	auto opBinaryRight(string op)(T num) if (mixin(opsList)) {
		auto a = this;
		
		mixin("a.v[] = num " ~ op ~ " a.v[];");
		
		return a;
	}
	
	/// eg. p1 += p2;
	auto opOpAssign(string op)(Pt o) if (mixin(opsList)) {
		assert(o.v.length == v.length);
		
		mixin("v[] " ~ op ~ "= o.v[];");
		
		return this;
	}
	
	/// eg. p1 += 2;
	auto opOpAssign(string op)(T num) if (mixin(opsList)) {
		mixin("v[] " ~ op ~ "= num;");
		
		return this;
	}
	
	//#the 'ref' stopped the internal error (Internal error: ..\ztc\cgcs.c 343)
	ref auto arrayD() {
		return v;
	}
	
	T arrayS(int a) {
		assert(a >= 0 && a < D);
		
		return v[a];
	}
	
	ref T X() @property {
		return  v[0];
	}
	
	ref T Y() @property {
		assert(D > 1);
		
		return  v[1];
	}
	
	auto Xi() @property {
		return cast(int)v[0];
	}
	
	auto Yi() @property {
		assert(D > 1);
		
		return cast(int)v[1];
	}
	
	string toString() {
		import std.conv;
		return text(v);
	}

	// ingredients //#?
	version(CanIncludeUnittests)
	unittest {
		import std.stdio : writeln;

		alias Pi = PointVec!(3, int); //#edit, Point to PointVec
		mixin(jecho("auto p = Pi(2, 5, 1);"));
		mixin(jecho("writeln(p);"));
		writeln();
		
		mixin(jecho("auto p2 = Pi(7, 8, 9);"));
		mixin(jecho("p = p2;"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(7, 8, 9));
		writeln();
		
		mixin(jecho("p = Pi(1, 2, 7);"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(1, 2, 7));
		writeln();
		
		mixin(jecho("p = Pi(0, 1, 2) + Pi(1, 1, 1);"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(1, 2, 3));
		writeln();
		
		mixin(jecho("p = Pi(1, 2, 3) * Pi(2, 2, 2);"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(2, 4, 6));
		writeln();
		
		mixin(jecho("p += Pi(1, 1, 1);"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(3, 5, 7));
		writeln();
		
		mixin(jecho("p *= Pi(2, 2, 2);"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(6, 10, 14));
		writeln();
		
		mixin(jecho("p = Pi(0, 1, 2) + Pi(1, 1, 1) - Pi(2,2,2);"));
		mixin(jecho("writeln(p);"));
		assert(p == Pi(-1, 0, 1));
		writeln();
		
		mixin(jecho("auto p3 = Pi(10,10,10);"));
		mixin(jecho("writeln(p + p3);"));
		writeln();
		
		mixin(jecho("auto z = Point(0,0);"));
		mixin(jecho("z += Point(1, 0);"));
		mixin(jecho("z += Point(1, 0);"));
		mixin(jecho(`writeln(z);`));
		assert(z == Point(2,0));
		writeln();
		
		mixin(jecho("z = Point(10, 20);"));
		mixin(jecho("z /= 2;"));
		mixin(jecho("writeln(z);"));
		assert(z == Point(5, 10));
		writeln("----------------------");
	}
}
