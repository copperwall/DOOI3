import std.stdio;

// Empty interface for ExprC expressions.
interface ExprC {}
interface Value {}

// ExprC class defintions
class NumC : ExprC {
   int n;

   this(int n) {
      this.n = n;
   }

   unittest
   {
      NumC num  = new NumC(5);
      assert(num.n == 4);

   }
}

class IdC : ExprC {
   string s;

   this(string s) {
      this.s = s;
   }
}

class TrueC : ExprC {

}

class FalseC : ExprC {

}


class BoolV : Value {
   bool b;

   this(bool b) {
      this.b = b;
   }
} 


class AppC : ExprC {
   ExprC fun;
   ExprC[] args;

   this(ExprC fun, ExprC[] args) {
      this.fun = fun;
      this.args = args;
   }
}

void main ()
{
   writeln("Hello World!!");
}


