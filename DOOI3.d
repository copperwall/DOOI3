import std.stdio;
import core.runtime;

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


}

class LamC : ExprC {
    string params;
    ExprC bod;

    this(string params, ExprC bod) {
	this.params = params;
	this.bod = bod;
    }
}

class IfC : ExprC {
    ExprC left;
    ExprC middle;
    ExprC right;

    this(ExprC left, ExprC middle, ExprC right) {
	this.left = left;
	this.middle = middle;
	this.right = right;
    }
}


class BinopC : ExprC {
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

////////////////////////////////////////////
// ExprC Definitions
////////////////////////////////////////////

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

////////////////////////////////////////////
// Interp
////////////////////////////////////////////

Value interp(ExprC c, Env e) {

}

////////////////////////////////////////////
// Tests
////////////////////////////////////////////


unittest {
      import std.stdio;
      
      writeln("Running first unit test!\n");
      NumC num  = new NumC(5);
      assert(num.n == 4);
      
}


//Interp tests
unittest {
    BinopC b1 = new BinopC("+", new NumC(1), new NumC(2));
    assert(interp(b1, []) == new NumV(3));

    BinopC b2 = new BinopC("-", new NumC(9), new IdC("dorf"));
    Env env2 = [new Binding("dorf, 6)];
    assert(interp(b2, env2) == new NumV(3));

    BinopC b3 = new BinopC("/", new BinopC("*", new NumC(2), new NumC(2)) new NumC(4));
    assert(interp(b3, []) == new NumV(1));
}


void main() {
   writeln("Program runs!");
}




