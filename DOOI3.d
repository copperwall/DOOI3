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

void main() {

}

/**
 * test
 *
 * @param ExprC expression - The expression to interpret.
 * @param string expected - The expected result to compare against
 */
bool test(ExprC expression, string expected) {
   return serialize(interp(expression, [])) == expected;
}

/**
 * test/exn
 *
 * @param ExprC expression - The expression to interpret.
 * @param string expected - The expected result to compare against
 */
bool test_exn(ExprC expression, string expected) {
   bool result = false;

   try {
      interp(expression, []);
   } catch (Error e) {
      result = (e.toString() == expected);
   }

   return result;
}
