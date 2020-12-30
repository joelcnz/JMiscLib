module jmisc.trig;

version(safe) {
@safe:
}

import jmisc.base;

import std.math;

immutable PIE = PI;

/// From point
void fromPoint(ref float magnitude, ref float direction, float[2] point) {
    immutable x = point[0],
        y = point[1];
    magnitude = sqrt(x ^^ 2 + y ^^ 2);
    direction  = atan2(y, x);
}

/// To point
float[2] toPoint(in float direction, in float magnitude) {
    immutable x = cos(direction) * magnitude;
    immutable y = sin(direction) * magnitude;

    return [x, y];
}

@safe float getAngle( float x, float y, float tx, float ty )
{
  return correct( atan2( ty - y, tx - x ) );
}

/// aim is the same as getAngle
alias aim = getAngle;

void PointXYDir(ref float xdir, ref float ydir,float xpos,float ypos,float xtarg,float ytarg, float spd) {
  xyaim(xdir,ydir, aim(xpos,ypos,xtarg,ytarg));
  xdir *= spd;
  ydir *= spd;
}
/*
void Project( float old_x, float old_y, float angle, float* new_x, float* new_y )
{
  float Sin = (float)sin(angle),
      Cos = (float)cos(angle);
  (*new_x)=( Cos*old_x - Sin*old_y ),
  (*new_y)=( Sin*old_x + Cos*old_y );
}

void ProjectXY( float old_x, float old_y, float angle, float *new_x, float *new_y ) {
  float Sin = (float)sin(angle),
      Cos = (float)cos(angle);
  (*new_x)+=( Cos*old_x - Sin*old_y ),
  (*new_y)+=( Sin*old_x + Cos*old_y );
}
#if 0
// eg
 __________________________
|         _                |
|        |     *           |
|      3-|      \          |
|         - .    \         |
|          /[___] \        |
|         /   |   x,y to = |
|        /    4            |
|      z,c, angle = 200    |
 --------------------------

ProjectXY( x,y, angle, &x,&y );
#endif
*/

// 2
bool inScope( float a, float ta, float sc ) {
//  float ata=correct( a-(ta-(scope/2)) );

  return correct( a-ta+sc/2 )<=sc;
//  ( ata<=scope ? 1 : 0);
}

int getDirection( float a, float ta, float sc ) {
  if ( inScope( a, ta, sc ) && correct( a-ta )!=PIE )
   return
     correct( a-ta )< PIE ? -1 : 1;
  else
   return 0;
}

//float abs( float v ) { return v<0 ? v*-1 : v; }

// 4
/// Quick distance
float quickDistance( float x,float y, float tx,float ty )
{
  return abs( x - tx ) + abs( y - ty );
}

// 7m
/// Keep within PI * 2
@safe float correct( float angle ) {
  immutable a=
//         2*PIE
          PI*2
  ;
  while ( angle>PI*2 ) angle-=a;
  while ( angle<0 ) angle+=a;

//  while ( angle>255 ) angle=0;
//  while ( angle<0 ) angle=255;

  return angle;
}

// 8
bool inrange( float x,float y, float tx,float ty, float range ) {
  return distance( x,y, tx,ty ) <= range;
}

/*
void Conv( float x, float y, float ox, float oy, float ang, int *nx, int *ny ) {
  int cx,cy;
  Cov( ox,oy, ang, &cx,&cy );
  (*nx)=(int)(x + cx);
  (*ny)=(int)(y + cy);
}

void Cov( float ox, float oy, float ang, int *cx, int *cy ) {
  float sn = sin(ang),
      cs = cos(ang);
  (*cx)=(int)( cs*ox - sn*oy ),
  (*cy)=(int)( sn*ox + cs*oy );
}

void Conv2( float x, float y, float ox, float oy, float ang,
            float *nx, float *ny ) {
  float cx,cy;
  Cov2( ox,oy, ang, &cx,&cy );
  (*nx)=x + cx;
  (*ny)=y + cy;
}

void Cov2( float ox, float oy, float ang, float *cx, float *cy ) {
  float sn = (float)sin(ang),
      cs = (float)cos(ang);
  (*cx)=( cs*ox - sn*oy ),
  (*cy)=( sn*ox + cs*oy );

#if 0
  new_x = x * cos (angle) -y * sin (angle)
  new_x = x * sin (angle) -y * cos (angle)
#endif
}
*/

// xyaim( &,&, aim( ) );

/// Aim for x and y
@safe void xyaim(ref float dx, ref float dy, float ang )
{
  dx=cos(ang);
  dy=sin(ang);
}

/+
/// Aim and move x and y
void aMove( float* mx,float* my, float stp, float ang ) {
  (*mx)+=stp*cos(ang);
  (*my)+=stp*sin(ang);
}


/// Aim and move just x
void aMovex( float *mx, float stp, float ang ) {
  (*mx)+=stp*cos(ang);
}

/// Aim and move just y
void aMovey( float *my, float stp, float ang ) {
  (*my)+=stp*sin(ang);
}
+/

/// Get distance template
auto distance(T)(PointVec!(2, T) a, PointVec!(2, T) b) {
    auto deltaX = a.X - b.X;
    auto deltaY = a.Y - b.Y;

	return sqrt((deltaX * deltaX) + (deltaY * deltaY));
}

/// Get distance template without using Point
@safe auto distance(T,T2,T3,T4)(T x, T2 y, T3 x2, T4 y2) {
    auto deltaX = x - x2;
    auto deltaY = y - y2;

	return sqrt((deltaX * deltaX) + (deltaY * deltaY));
}
