import std.stdio;

////////////////////////////////////////////
// ExprC Definitions
////////////////////////////////////////////

// Empty interface for ExprC expressions.
interface ExprC {}
interface Value {}

class Binding {
   string name;
   Value val;
}

alias Env = Binding[];

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

class LamC : ExprC {   
    string params;
    ExprC bod;

    this(string params, ExprC bod) {
	this.params = params;
	this.bod = bod;
    }
}

class If : ExprC {
    ExprC left;
    ExprC middle;
    ExprC right;

    this(ExprC left, ExprC middle, ExprC right) {
	this.left = left;
	this.middle = middle;
	this.right = right;
    }
}


class Binop : ExprC {
    string name;
    ExprC left;
    ExprC right;

    this(string name, ExprC left, ExprC right) {
	this.name = name;
	this. left = left;
	this.right = right;
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

class AppC : ExprC {
   ExprC fun;
   ExprC[] args;
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



Value interp(ExprC c, Env e) {

}


void main() {

}

