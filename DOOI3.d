import std.stdio;

// Empty interface for ExprC expressions.
interface ExprC {}
interface Value {}

class Binding {
   string name;
   Value val;
}

alias Env = Binding[];

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

class TrueC : ExprC {}
class FalseC : ExprC {}

class NumV : Value {
   int n;

   this(int n) {
      this.n = n;
   }
}

class BoolV : Value {
   bool b;

   this(bool b) {
      this.b = b;
   }
}

class ClosV : Value {
   string[] args;
   ExprC bod;
   Env e;

   this(string[] args, ExprC bod, Env e) {
      this.args = args;
      this.bod = bod;
      this.e = e;
   }
}
