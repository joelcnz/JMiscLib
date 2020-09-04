module jmisc.trig;

version(safe) {
@safe:
}

import jmisc.base;

import std.math;

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

/*
void Project( double old_x, double old_y, double angle, double* new_x, double* new_y )
{
  double Sin = (double)sin(angle),
      Cos = (double)cos(angle);
  (*new_x)=( Cos*old_x - Sin*old_y ),
  (*new_y)=( Sin*old_x + Cos*old_y );
}

void ProjectXY( double old_x, double old_y, double angle, double *new_x, double *new_y ) {
  double Sin = (double)sin(angle),
      Cos = (double)cos(angle);
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

/*
// 2
int inScope( double a, double ta, double scope ) {
//  double ata=correct( a-(ta-(scope/2)) );

  return ( correct( a-ta+scope/2 )<=scope ? 1 : 0);
//  ( ata<=scope ? 1 : 0);
}

int isRight( double a, double ta, double scope ) {
  if ( inScope( a, ta, scope ) && correct( a-ta )!=PIE )
   return
     ( correct( a-ta )< PIE ? -1 : 1 );
  else
   return 0;
}
*/
//double abs( double v ) { return v<0 ? v*-1 : v; }

// 4
/// Quick distance
double quickDistance( double x,double y, double tx,double ty )
{
  return abs( x - tx ) + abs( y - ty );
}

// 7m
/// Keep within PI * 2
@safe double correct( double angle ) {
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
bool inrange( double x,double y, double tx,double ty, double range ) {
  return distance( x,y, tx,ty ) <= range;
}

/*
void Conv( double x, double y, double ox, double oy, double ang, int *nx, int *ny ) {
  int cx,cy;
  Cov( ox,oy, ang, &cx,&cy );
  (*nx)=(int)(x + cx);
  (*ny)=(int)(y + cy);
}

void Cov( double ox, double oy, double ang, int *cx, int *cy ) {
  double sn = sin(ang),
      cs = cos(ang);
  (*cx)=(int)( cs*ox - sn*oy ),
  (*cy)=(int)( sn*ox + cs*oy );
}

void Conv2( double x, double y, double ox, double oy, double ang,
            double *nx, double *ny ) {
  double cx,cy;
  Cov2( ox,oy, ang, &cx,&cy );
  (*nx)=x + cx;
  (*ny)=y + cy;
}

void Cov2( double ox, double oy, double ang, double *cx, double *cy ) {
  double sn = (double)sin(ang),
      cs = (double)cos(ang);
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
void aMove( double* mx,double* my, double stp, double ang ) {
  (*mx)+=stp*cos(ang);
  (*my)+=stp*sin(ang);
}


/// Aim and move just x
void aMovex( double *mx, double stp, double ang ) {
  (*mx)+=stp*cos(ang);
}

/// Aim and move just y
void aMovey( double *my, double stp, double ang ) {
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
