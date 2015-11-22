import std.stdio;
import core.runtime;
import std.conv;

////////////////////////////////////////////
// ExprC Definitions
////////////////////////////////////////////

// Empty interface for ExprC expressions.
interface ExprC {}
interface Value {}

class Binding {

   string name;
   Value val;

   this(string name, Value val) {
      this.name = name;
      this.val = val;
   }
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

string serialize(Value v) {
   if (cast(NumV)v) {
      NumV n = cast(NumV)v;
      return to!string(n.n);
   } else if (cast(BoolV)v) {
      BoolV b = cast(BoolV)v;
      return b.b ? "true" : "false";
   } else if (cast(ClosV)v) {
      return "#<procedure>";
   }

   throw new Error("Invalid Value");
}

Value interp(ExprC c, Env e) {
   throw new Error("Unimplemented");
}

////////////////////////////////////////////
// Tests
////////////////////////////////////////////


unittest {
      import std.stdio;
      
      writeln("Running unit tests...\n");
      NumC num  = new NumC(5);
      assert(num.n == 5);

      NumV numV  = new NumV(5);
      assert(numV.n == 5);

      BoolV boo = new BoolV(false);
      assert(boo.b == false);

      IdC id = new IdC("x");
      assert(id.s == "x");

      Binding one = new Binding("x", numV);
      Binding two = new Binding("y", numV);
      Env env = [];
      env = env ~ one;
      env = env ~ two;

      assert(env[0] == one);
      assert(env[1] == two);



      LamC func = new LamC("x y z", num);


      string[] args = ["x", "y", "z"];
      ClosV cloV = new ClosV(args, num, env);


      assert(cloV.args == ["x", "y", "z"]);
      assert(cloV.bod == num);
      assert(cloV.e == env);






      writeln("Tests complete...");
}

unittest {
    BinopC b1 = new BinopC("+", new NumC(1), new NumC(2));
    assert(interp(b1, []) == new NumV(3));
 
    BinopC b2 = new BinopC("-", new NumC(9), new IdC("dorf"));
    Env env2 = [new Binding("dorf", 6)];
    assert(interp(b2, env2) == new NumV(3));
 
    BinopC b3 = new BinopC("/", new BinopC("*", new NumC(2), new NumC(2)) new NumC(4));
    assert(interp(b3, []) == new NumV(1));
 }



void main() {
   writeln("Program runs!");
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
