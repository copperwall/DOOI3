import std.stdio;

// Empty interface for ExprC expressions.
interface ExprC {}

// ExprC class defintions
class NumC : ExprC {
   int n;

   this(int n) {
      this.n = n;
   }
}

class IdC : ExprC {
   string s;

   this(string s) {
      this.s = s;
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
