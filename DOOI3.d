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


Value interp_booC(ExprC xp, Env e) {
  if (cast (TrueC) xp ) { 
    return (cast (Value) new BoolV(true));
  }
  else {
    return (cast (Value) new BoolV(false));
  }
}




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

Value lookup(string s, Env e) {
   for (size_t i = 0; i < e.length; i++) {
      if (e[i].name == s) {
         return e[i].val;
      }
   }

   throw new Error("Unbound variable");
}

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
         } else {
            throw new Error("Wrong arity");
         }
      } else {
         throw new Error("Can't apply args to non function");
      }
   } else if (cast (IfC) c ) {
    IfC ifExp = cast (IfC) c;
    Value condition = interp(ifExp.left, e);

    if (cast (BoolV) condition) {
      BoolV condBool = (cast(BoolV) condition);
      if (condBool.b == true) {

        return interp(ifExp.middle, e);
      }
      else if(condBool.b == false) {
        return interp(ifExp.right, e);
      }

    }
  }
  
  else if (cast (LamC) c) {
    LamC l = (cast (LamC) c);
    ClosV cloV = new ClosV(l.params, l.bod, e);
    return (cast (Value) cloV);
  }


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

//unittest {
//  //BINOP TESTS
//    BinopC b1 = new BinopC("+", new NumC(1), new NumC(2));
//    assert(interp(b1, []) == new NumV(3));

//    BinopC b2 = new BinopC("-", new NumC(9), new IdC("dorf"));
//    Env env2 = [new Binding("dorf", 6)];
//    assert(interp(b2, env2) == new NumV(3));

//    BinopC b3 = new BinopC("/", new BinopC("*", new NumC(2), new NumC(2)), new NumC(4));
//    assert(interp(b3, []) == new NumV(1));

//  //IF TESTS
//    IfC if1 = new IfC(new TrueC(), new BinopC("+", new IdC("hey"), new NumC(1)), new FalseC());
//    assert(interp(if1, [new Binding("hey", 5)]) == 6);

//    IfC if2 = new IfC(new FalseC(), new TrueC(), new BinopC("+", new IdC("eh"), new IdC("whaddup")));
//    assert(interp(if2, [new Binding("eh", 5), new Binding("whaddup", 4)]) == 9);

//  //LamC Tests
// }



void main() {

  writeln ("TESTING IFC" );

   assert(test(new IfC(new TrueC(),
               new NumC(10),
               new NumC(20)),
            "10"));
   assert(test(new IfC(new FalseC(),
               new NumC(10),
               new NumC(11)),
            "11"));
   assert(test(new IfC(new BinopC("eq?",
                     new NumC(10),
                     new NumC(10)),
                  new NumC(12),
                  new NumC(20)),
               "12"));

   assert(test(new AppC(new LamC(["a", "b"],
                  new BinopC("+", new IdC("a"), new IdC("b"))),
                  [new NumC(10), new NumC(20)]), "30"));

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
