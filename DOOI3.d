import std.stdio;
import core.runtime;
import std.conv;
import std.algorithm;

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
    string[] params;
    ExprC bod;

     this(string[] params, ExprC bod) {
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

/**
 * Serialize Value type into a string.
 */
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

   throw new Exception("Invalid Value");
}

/**
 * Given a string s, return the first value that corresponds to that string in
 * the environment.
 */
Value lookup(string s, Env e) {
   for (size_t i = 0; i < e.length; i++) {
      if (e[i].name == s) {
         return e[i].val;
      }
   }

   throw new Exception("Unbound variable");
}

/**
 * Takes an expression and an environment and returns the interpreted Value.
 */
Value interp(ExprC c, Env e) {
   if (cast (NumC) c) {
      NumC n = cast (NumC) c;
      return new NumV(n.n);
   } else if (cast (IdC) c) {
      IdC i = cast (IdC) c;
      return lookup(i.s, e);
   } else if (cast (AppC) c) {
      AppC a = cast (AppC) c;
      Value fv = interp(a.fun, e);

      if (auto cv = (cast (ClosV) fv)) {
         if (cv.args.length == a.args.length) {
            auto values = map!(a => interp(a, e))(a.args);
            auto cenv = cv.e;

            for (size_t i = 0; i < a.args.length; i++) {
               auto b = new Binding(cv.args[i], values[i]);
               cenv = b ~ cenv;
            }

            return interp(cv.bod, cenv);
         } else
            throw new Exception("Wrong arity");
      } else
         throw new Exception("Can't apply args to non function");
   } else if (cast (IfC) c) {
    IfC ifExp = cast (IfC) c;
    Value condition = interp(ifExp.left, e);

    if (cast (BoolV) condition) {
      BoolV condBool = (cast(BoolV) condition);
      if (condBool.b == true)
        return interp(ifExp.middle, e);
      else if(condBool.b == false)
        return interp(ifExp.right, e);
    }
  } else if (cast (LamC) c) {
    LamC l = (cast (LamC) c);
    return new ClosV(l.params, l.bod, e);
  } else if (cast(BinopC) c){
      BinopC binop = cast(BinopC) c;
      Value left = interp(binop.left, e);
      Value right = interp(binop.right, e);
      string op = binop.name;

      if ((cast (NumV) left) && (cast (NumV) right))
        return evalNumBinop(op, left, right);
      else if (op == "eq?" && typeid(left) == typeid(BoolV) && typeid(right) == typeid(BoolV))
        return new BoolV(left == right);
      else
        throw new Exception("No such operator");
   } else if (cast (TrueC) c)
      return new BoolV(true);
   else if (cast (FalseC) c)
      return new BoolV(false);

   throw new Exception("Unimplemented");
}

/**
 * Takes a binary operator and two Values. Returns the result of the
 * appropriate binary operation.
 */
Value evalNumBinop(string op, Value left, Value right) {
  int newLeft = (cast(NumV) left).n;
  int newRight = (cast(NumV) right).n;

  switch (op)
  {
    case "+":
      return new NumV(newLeft + newRight);

    case "-":
      return new NumV(newLeft - newRight);

    case "/":
      return new NumV(newLeft / newRight);

    case "*":
      return new NumV(newLeft * newRight);

    case "<=":
      return new BoolV(newLeft <= newRight);

    case "eq?":
      return new BoolV(newLeft == newRight);

    default:
      throw new Exception("No such arithmetic operator");
  }
}

////////////////////////////////////////////
// Tests
////////////////////////////////////////////

//Interp tests
unittest {
      writeln("Running unit tests...\n");
      NumC num  = new NumC(5);
      assert(num.n == 5);

      NumV numV  = new NumV(5);
      assert(numV.n == 5);

      BoolV boolV = new BoolV(false);
      assert(boolV.b == false);

      IdC id = new IdC("x");
      assert(id.s == "x");

      Binding one = new Binding("x", numV);
      Binding two = new Binding("y", numV);
      Env env = [];
      env = env ~ one;
      env = env ~ two;

      assert(env[0] == one);
      assert(env[1] == two);

      BinopC binop = new BinopC("+", num, num);
      assert(binop.name == "+");
      assert(binop.left == num);
      assert(binop.right == num);

      string[] args = ["x", "y", "z"];

      LamC func = new LamC(args, num);
      assert(func.params == ["x", "y", "z"]);
      assert(func.bod == num);

      ClosV cloV = new ClosV(args, num, env);

      assert(cloV.args == ["x", "y", "z"]);
      assert(cloV.bod == num);
      assert(cloV.e == env);

      AppC app = new AppC(func, [num]);
      assert(app.fun == func);
      assert(app.args == [num]);

      ExprC[] expArgs = [];
      expArgs = expArgs ~ num;
      expArgs = expArgs ~ id;

      app = new AppC(func, expArgs);
      assert(app.args == expArgs);

      writeln("Tests complete...");
}

unittest {
    // Binop Tests
    BinopC b1 = new BinopC("+", new NumC(1), new NumC(2));
    assert(serialize(interp(b1, [])) == "3");

    BinopC b2 = new BinopC("-", new NumC(9), new IdC("dorf"));
    Env env2 = [new Binding("dorf", new NumV(6))];
    assert(serialize(interp(b2, env2)) == "3");


    BinopC b3 = new BinopC("/", new BinopC("*", new NumC(2), new NumC(2)), new NumC(4));
    assert(serialize(interp(b3, [])) == "1");


    // If Tests
    IfC if1 = new IfC(new TrueC(), new BinopC("+", new IdC("hey"), new NumC(1)), new FalseC());
    assert(serialize(interp(if1, [new Binding("hey", new NumV(5))])) == "6");

    IfC if2 = new IfC(new FalseC(), new TrueC(), new BinopC("+", new IdC("eh"), new IdC("whaddup")));
    assert(serialize(interp(if2, [new Binding("eh", new NumV(5)), new Binding("whaddup", new NumV(4))])) == "9");
}

void main() {
   writeln("Running functional tests");
   assert(test(new IfC(new TrueC(),
               new NumC(10),
               new NumC(20)),
            "10"));
   write(".");
   assert(test(new IfC(new FalseC(),
               new NumC(10),
               new NumC(11)),
            "11"));
   write(".");
   assert(test(new IfC(new BinopC("eq?",
                     new NumC(10),
                     new NumC(10)),
                  new NumC(12),
                  new NumC(20)),
               "12"));
   write(".");
   assert(test(new AppC(new LamC(["a", "b"],
                  new BinopC("+", new IdC("a"), new IdC("b"))),
                  [new NumC(10), new NumC(20)]), "30"));
   write(".");
   assert(test(new AppC(
               new AppC(
                  new LamC(["x"],
                     new LamC(["y"],
                        new BinopC("+",
                           new IdC("x"),
                           new IdC("y")))),
                  [new NumC(5)]),
               [new NumC(10)]),
            "15"));
   write(".");
   assert(test_exn(new BinopC("^", new NumC(10), new NumC(20)),
            "No such arithmetic operator"));
   write(".");
   writeln("\nFunctional Tests Complete.");
}

/**
 * Takes an expression and an expected value and returns whether or not they
 * match.
 *
 * @param ExprC expression - The expression to interpret.
 * @param string expected - The expected result to compare against
 */
bool test(ExprC expression, string expected) {
   return serialize(interp(expression, [])) == expected;
}

/**
 * Takes an expression and an expected error message.
 *
 * @param ExprC expression - The expression to interpret.
 * @param string expected - The expected result to compare against
 */
bool test_exn(ExprC expression, string expected) {
   bool result = false;

   try {
      interp(expression, []);
   } catch (Exception e) {
      result = (e.msg == expected);
   }

   return result;
}
