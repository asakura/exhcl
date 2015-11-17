defmodule ExhclTest do
  use ExUnit.Case
  import Exhcl.Parser

  doctest Exhcl

  test "lexer" do
    assert {:ok, [], _} = :exhcl_lexer.string('')
    assert {:ok, ["[": 1, "]": 1], _} = :exhcl_lexer.string('[]')
    assert {:ok,
            [{:"[", 1},
             {:integer, 1, 1},
             {:integer, 1, 2},
             {:"]", 1}], 1} = :exhcl_lexer.string('[1, 2]')
    assert {:ok,
            [{:"[", 1},
             {:integer, 1, 1},
             {:integer, 1, 2},
             {:integer, 1, 3},
             {:"]", 1}], 1} = :exhcl_lexer.string('[1, 2,3]')
    assert {:ok,
            [{:"[", 1},
             {:integer, 1, 1},
             {:integer, 2, 2},
             {:integer, 4, 3},
             {:"]", 4}], 4} = :exhcl_lexer.string('[1,\n2,\n\n3]')

    assert {:ok, ["{": 1, "}": 1], _} = :exhcl_lexer.string('{}')
    assert {:ok, [], _} = :exhcl_lexer.string(',')
    assert {:ok, ["=": 1], _} = :exhcl_lexer.string('=')

    assert {:ok, [], _} = :exhcl_lexer.string('// comment')
    assert {:ok, [], _} = :exhcl_lexer.string('# comment \n #comment')
    assert {:ok, [], _} = :exhcl_lexer.string('/* comment */')
    assert {:ok, [], _} = :exhcl_lexer.string('/* comment \n \n\n*/')

    assert {:ok, [{:atom, 1, :a}, {:=, 1}, {:atom, 1, :b}],
            _} = :exhcl_lexer.string('a = b')

    assert {:ok,
            [{:atom, 1, :a}, {:=, 1},
             {:atom, 1, :b}, {:atom, 2, :c},
             {:=, 2}, {:atom, 2, :d}], 2} = :exhcl_lexer.string('a = b \n c = d')

    assert {:ok,
            [{:atom, 1, :a}, {:=, 1}, {:atom, 1, :b},
             {:atom, 1, :c}, {:=, 1}, {:atom, 1, :d}], 1} = :exhcl_lexer.string('a = b, c = d')

    assert {:ok, [{:atom, 1, :test}, {:"{", 1},
                  {:atom, 1, :a}, {:=, 1},
                  {:atom, 1, :b}, {:"}", 1}],
            _} = :exhcl_lexer.string('test {a = b}')

    assert {:ok, [{:text, 1, "text"}], 1} = :exhcl_lexer.string('"text"')
    assert {:ok,
            [{:atom, 1, :config}, {:text, 1, "text"},
             {:"{", 1}, {:"}", 1}], 1} = :exhcl_lexer.string('config "text" {}')
  end

  test "lexer -> integer" do
    assert {:ok, [{:integer, 1, 0}], _} = :exhcl_lexer.string('0')
    assert {:ok, [{:integer, 1, 1}], _} = :exhcl_lexer.string('1')
    assert {:ok, [{:integer, 1, 5}], _} = :exhcl_lexer.string('5')
    assert {:ok, [{:integer, 1, 50}], _} = :exhcl_lexer.string('50')
    assert {:ok, [{:integer, 1, 0}], _} = :exhcl_lexer.string('00')
    assert {:ok, [{:integer, 1, 1}], _} = :exhcl_lexer.string('01')
    assert {:ok, [{:integer, 1, 6}], _} = :exhcl_lexer.string('06')
    assert {:ok, [{:integer, 1, 90}], _} = :exhcl_lexer.string('0090')

    assert {:ok, [{:integer, 1, 0}], _} = :exhcl_lexer.string('-0')
    assert {:ok, [{:integer, 1, -1}], _} = :exhcl_lexer.string('-1')
    assert {:ok, [{:integer, 1, -5}], _} = :exhcl_lexer.string('-5')
    assert {:ok, [{:integer, 1, -50}], _} = :exhcl_lexer.string('-50')
    assert {:ok, [{:integer, 1, 0}], _} = :exhcl_lexer.string('-00')
    assert {:ok, [{:integer, 1, -1}], _} = :exhcl_lexer.string('-01')
    assert {:ok, [{:integer, 1, -6}], _} = :exhcl_lexer.string('-06')
    assert {:ok, [{:integer, 1, -90}], _} = :exhcl_lexer.string('-0090')

    assert {:ok, [{:integer, 1, 0}], _} = :exhcl_lexer.string('+0')
    assert {:ok, [{:integer, 1, 1}], _} = :exhcl_lexer.string('+1')
    assert {:ok, [{:integer, 1, 5}], _} = :exhcl_lexer.string('+5')
    assert {:ok, [{:integer, 1, 50}], _} = :exhcl_lexer.string('+50')
    assert {:ok, [{:integer, 1, 0}], _} = :exhcl_lexer.string('+00')
    assert {:ok, [{:integer, 1, 1}], _} = :exhcl_lexer.string('+01')
    assert {:ok, [{:integer, 1, 6}], _} = :exhcl_lexer.string('+06')
    assert {:ok, [{:integer, 1, 90}], _} = :exhcl_lexer.string('+0090')
  end

  test "lexer -> float" do
    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0')
    assert {:ok, [{:float, 1, 0.1}], _} = :exhcl_lexer.string('0.1')
    assert {:ok, [{:float, 1, 1.0}], _} = :exhcl_lexer.string('1.0')
    assert {:ok, [{:float, 1, 1.02}], _} = :exhcl_lexer.string('1.02')
    assert {:ok, [{:float, 1, 50.05}], _} = :exhcl_lexer.string('50.05')
    assert {:ok, [{:float, 1, 10.00001}], _} = :exhcl_lexer.string('0010.00001')
    assert {:ok, [{:float, 1, 0.0002}], _} = :exhcl_lexer.string('0.00020000')
    assert {:ok, [{:float, 1, 9.10}], _} = :exhcl_lexer.string('009.10')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('-0.0')
    assert {:ok, [{:float, 1, -0.1}], _} = :exhcl_lexer.string('-0.1')
    assert {:ok, [{:float, 1, -1.0}], _} = :exhcl_lexer.string('-1.0')
    assert {:ok, [{:float, 1, -1.02}], _} = :exhcl_lexer.string('-1.02')
    assert {:ok, [{:float, 1, -50.05}], _} = :exhcl_lexer.string('-50.05')
    assert {:ok, [{:float, 1, -10.00001}], _} = :exhcl_lexer.string('-0010.00001')
    assert {:ok, [{:float, 1, -0.0002}], _} = :exhcl_lexer.string('-0.00020000')
    assert {:ok, [{:float, 1, -9.10}], _} = :exhcl_lexer.string('-009.10')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('+0.0')
    assert {:ok, [{:float, 1, 0.1}], _} = :exhcl_lexer.string('+0.1')
    assert {:ok, [{:float, 1, 1.0}], _} = :exhcl_lexer.string('+1.0')
    assert {:ok, [{:float, 1, 1.02}], _} = :exhcl_lexer.string('+1.02')
    assert {:ok, [{:float, 1, 50.05}], _} = :exhcl_lexer.string('+50.05')
    assert {:ok, [{:float, 1, 10.00001}], _} = :exhcl_lexer.string('+0010.00001')
    assert {:ok, [{:float, 1, 0.0002}], _} = :exhcl_lexer.string('+0.00020000')
    assert {:ok, [{:float, 1, 9.10}], _} = :exhcl_lexer.string('+009.10')
  end

  test "lexer -> float -> scientific" do
    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0e10')
    assert {:ok, [{:float, 1, 1.0e10}], _} = :exhcl_lexer.string('0.1e11')
    assert {:ok, [{:float, 1, 1.0e9}], _} = :exhcl_lexer.string('1.0e09')
    assert {:ok, [{:float, 1, 1.02e15}], _} = :exhcl_lexer.string('1.02e15')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0E10')
    assert {:ok, [{:float, 1, 1.0e10}], _} = :exhcl_lexer.string('0.1E11')
    assert {:ok, [{:float, 1, 1.0e9}], _} = :exhcl_lexer.string('1.0E09')
    assert {:ok, [{:float, 1, 1.02e15}], _} = :exhcl_lexer.string('1.02E15')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0e+10')
    assert {:ok, [{:float, 1, 1.0e10}], _} = :exhcl_lexer.string('0.1e+11')
    assert {:ok, [{:float, 1, 1.0e9}], _} = :exhcl_lexer.string('1.0e+9')
    assert {:ok, [{:float, 1, 1.02e15}], _} = :exhcl_lexer.string('1.02e+15')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0E+10')
    assert {:ok, [{:float, 1, 1.0e10}], _} = :exhcl_lexer.string('0.1E+11')
    assert {:ok, [{:float, 1, 1.0e9}], _} = :exhcl_lexer.string('1.0E+9')
    assert {:ok, [{:float, 1, 1.02e15}], _} = :exhcl_lexer.string('1.02E+15')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0e-10')
    assert {:ok, [{:float, 1, 1.0e-12}], _} = :exhcl_lexer.string('0.1e-11')
    assert {:ok, [{:float, 1, 1.0e-9}], _} = :exhcl_lexer.string('1.0e-9')
    assert {:ok, [{:float, 1, 1.02e-15}], _} = :exhcl_lexer.string('1.02e-15')

    assert {:ok, [{:float, 1, 0.0}], _} = :exhcl_lexer.string('0.0E-10')
    assert {:ok, [{:float, 1, 1.0e-12}], _} = :exhcl_lexer.string('0.1E-11')
    assert {:ok, [{:float, 1, 1.0e-9}], _} = :exhcl_lexer.string('1.0E-9')
    assert {:ok, [{:float, 1, 1.02e-15}], _} = :exhcl_lexer.string('1.02E-15')
  end

  test "parser" do
    assert {:ok, %{}} = parse()
    assert {:ok, %{}} = parse("")

    assert {:ok, %{a: [1, 2], b: %{b: 3}}} = parse("a = [1, 2], b {b = 3}")
    assert {:ok, %{a: [1, 2, %{b: 3}]}} = parse("a = [1, 2, {b = 3}]")

    assert {:ok, %{a: %{b: %{c: 3}}}} = parse("a {b {c = 3}}")

    assert {:ok, %{a: %{x: %{x1: 1}, y: 2}}} = parse("a {x {x1 = 1}}, a {y = 2}")
    assert {:ok, %{test1: %{test2: %{test3: %{"test4" => %{a: 1}}}}}} = parse("test1 test2 test3 \"test4\" {a = 1}")
    assert {:ok, %{test: %{a: 1, b: 2, test: %{c: 3}}}} = parse("test {a = 1} test {b = 2} test test {c = 3}")
    assert {:ok, %{test: %{"aa" => %{y: %{x: %{a: 2}}}}}} = parse("test \"aa\" {y x { a = 2} }")
    assert {:ok, %{test: %{"aa" => %{a: 1, b: 2, y: %{x: %{a: 2}}}}}} = parse("test \"aa\" {a = 1 \n b = 2 \n y x { a = 2} }")
    assert {:ok, %{test: %{"aa" => %{a: 1, b: 2}}}} = parse("test \"aa\" {a = 1, b = 2}")
    assert {:ok, %{test: %{"aa" => %{a: 1, b: 2}}}} = parse("test \"aa\" {a = 1, \n b = 2}")
  end

  test "parse: root object (atom, integers)" do
    assert {:ok, %{a: 1}} = parse(
      ~S(
        a = 1
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1, b = 2
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1,
        b = 2
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1
        ,b = 2
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1
        b = 2
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1
        ,b = 2
        b = 2
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1
        ,b = 2
        b = 2,
      ))
  end

  test "parse: root object (atom, text)" do
    assert {:ok, %{a: "1"}} = parse(
      ~S(
        a = "1"
      ))

    assert {:ok, %{a: "1", b: "2"}} = parse(
      ~S(
        a = "1", b = "2"
      ))

    assert {:ok, %{a: "1", b: "2"}} = parse(
      ~S(
        a = "1",
        b = "2"
      ))

    assert {:ok, %{a: "1", b: "2"}} = parse(
      ~S(
        a = "1"
        ,b = "2"
      ))

    assert {:ok, %{a: "1", b: "2"}} = parse(
      ~S(
        a = "1"
        b = "2"
      ))

    assert {:ok, %{a: "1", b: "2"}} = parse(
      ~S(
        a = "1"
        ,b = "2"
        b = "2"
      ))

    assert {:ok, %{a: "1", b: "2"}} = parse(
      ~S(
        a = "1"
        ,b = "2"
        b = "2",
      ))
  end

  test "parse: root object (text, text)" do
    assert {:ok, %{"a" => "1"}} = parse(
      ~S(
        "a" = "1"
      ))

    assert {:ok, %{"a" => "1", "b" => "2"}} = parse(
      ~S(
        "a" = "1", "b" = "2"
      ))

    assert {:ok, %{"a" => "1", "b" => "2"}} = parse(
      ~S(
        "a" = "1",
        "b" = "2"
      ))

    assert {:ok, %{"a" => "1", "b" => "2"}} = parse(
      ~S(
        "a" = "1"
        ,"b" = "2"
      ))

    assert {:ok, %{"a" => "1", "b" => "2"}} = parse(
      ~S(
        "a" = "1"
        "b" = "2"
      ))

    assert {:ok, %{"a" => "1", "b" => "2"}} = parse(
      ~S(
        "a" = "1"
        ,"b" = "2"
        "b" = "2"
      ))

    assert {:ok, %{"a" => "1", "b" => "2"}} = parse(
      ~S(
        "a" = "1"
        ,"b" = "2"
        "b" = "2",
      ))
  end

  test "parse: comments in root object" do
    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1
        b = 2 # comment
      ))

    assert {:ok, %{a: 1}} = parse(
      ~S(
        a = 1
        # b = 2
      ))

    assert {:ok, %{}} = parse(
      ~S(
        /* a = 1
        */ b = 2
      ))

    assert {:ok, %{a: 1, b: 2}} = parse(
      ~S(
        a = 1
        b = 2 // comment
      ))

    assert {:ok, %{a: 1}} = parse(
      ~S(
        a = 1
        // b = 2
      ))

    assert {:ok, %{}} = parse(
      ~S(
        // a = 1
        // b = 2
      ))
  end

  test "parse: basic arrays" do
    assert {:ok, %{a: []}} = parse(
      ~S(
        a = []
      ))

    assert {:ok, %{a: [1]}} = parse(
      ~S(
        a = [1]
      ))

    assert {:ok, %{a: [1, 2]}} = parse(
      ~S(
        a = [1, 2]
      ))

    assert {:ok, %{a: [1, 2]}} = parse(
      ~S(
        a = [1,
             2]
      ))

    assert {:ok, %{a: [1, 2]}} = parse(
      ~S(
        a = [
           1,
           2
         ]
      ))

    assert {:ok, %{a: [1, 2]}} = parse(
      ~S(
        a = [
            1
           ,2
         ]
      ))

    assert {:ok, %{a: [1, 2]}} = parse(
      ~S(
        a = [
           1,
           2,
         ]
      ))

    assert {:ok, %{a: [1, "str"]}} = parse(
      ~S(
        a = [1, "str"]
      ))

    assert {:ok, %{a: [1, "str", 2]}} = parse(
      ~S(
        a = [1, "str", 2]
      ))

    assert {:ok, %{a: [1, "str", 2]}} = parse(
      ~S(
        a = [1,
             "str",
             2]
      ))

    assert {:ok, %{a: [1, "str", 2]}} = parse(
      ~S(
        a = [
           1,
           "str",
           2
         ]
      ))

    assert {:ok, %{a: [1, "str", 2]}} = parse(
      ~S(
        a = [
           1
           ,"str"
           ,2
         ]
      ))

    assert {:ok, %{a: [1, "str", 2]}} = parse(
      ~S(
        a = [
           1,
           "str",
           2,
         ]
      ))

    assert {:ok, %{a: [1, "str", 0.9]}} = parse(
      ~S(
        a = [1, "str", 0.9]
      ))

    assert {:ok, %{a: [1, "str", 0.9, 2]}} = parse(
      ~S(
        a = [1, "str", 0.9, 2]
      ))

    assert {:ok, %{a: [1, "str", 0.9, 2]}} = parse(
      ~S(
        a = [1,
             "str",
             0.9,
             2]
      ))

    assert {:ok, %{a: [1, "str", 0.9, 2]}} = parse(
      ~S(
        a = [
           1,
           "str",
           0.9,
           2
         ]
      ))

    assert {:ok, %{a: [1, "str", 0.9, 2]}} = parse(
      ~S(
        a = [
           1
           ,"str"
           ,0.9
           ,2
         ]
      ))

    assert {:ok, %{a: [1, "str", 0.9, 2]}} = parse(
      ~S(
        a = [
           1,
           "str",
           0.9,
           2,
         ]
      ))
  end

  test "parse: arrays in arrays" do
    assert {:ok, %{a: [1, 2, [1]]}} = parse(
      ~S(
        a = [1, 2, [1]]
      ))

    assert {:ok, %{a: [1, 2, [1]]}} = parse(
      ~S(
        a = [1, 2,
             [1]]
      ))

    assert {:ok, %{a: [1, 2, [1, 3]]}} = parse(
      ~S(
        a = [1, 2, [1
                    , 3]]
      ))

    assert {:ok, %{a: [1, 2, [1, "str"]]}} = parse(
      ~S(
        a = [1, 2, [1, "str"]]
      ))

    assert {:ok, %{a: [1, 2, [1, "str"]]}} = parse(
      ~S(
        a = [1, 2,
             [1, "str"]]
      ))

    assert {:ok, %{a: [1, 2, [1, 3, "str"]]}} = parse(
      ~S(
        a = [1, 2, [1
                    , 3
                    , "str"]]
      ))

    assert {:ok, %{a: [1, 2, [1, "str", 0.9]]}} = parse(
      ~S(
        a = [1, 2, [1, "str", 0.9]]
      ))

    assert {:ok, %{a: [1, 2, [1, "str", 0.9]]}} = parse(
      ~S(
        a = [1, 2,
             [1, "str", 0.9]]
      ))

    assert {:ok, %{a: [1, 2, [1, 3, "str", 0.9]]}} = parse(
      ~S(
        a = [1, 2, [1
                    , 3
                    , "str"
                    , 0.9]]
      ))
  end

  test "parse: comments in arrays" do
    assert {:ok, %{test: [1, 2, 3]}} = parse(
      ~S(
        test = [
           1,
           2,
           3 # comment
         ]
      )
    )

    assert {:ok, %{test: [1, 2]}} = parse(
      ~S(
        test = [
           1,
           2,
           # 3 # comment
         ]
      )
    )

    assert {:ok, %{test: [3]}} = parse(
      ~S(
        test = [
           /* 1,
           2, */
           3
         ]
      )
    )
  end

  test "parse: basic objects" do
    assert {:ok, %{test: %{}}} = parse(
      ~S(
        test {}
      ))

    assert {:ok, %{test: %{a: 1}}} = parse(
      ~S(
        test {a = 1}
      ))

    assert {:ok, %{test: %{a: 1, b: 2}}} = parse(
      ~S(
        test {a = 1, b = 2}
      ))

    assert {:ok, %{test: %{a: 1, b: 2}}} = parse(
      ~S(
        test {a = 1, b = 1, b = 2}
      ))

    assert {:ok, %{test: %{a: 1, b: 2}}} = parse(
      ~S(
        test {a = 1,
              b = 2}
      ))

    assert {:ok, %{test: %{a: 1, b: 2}}} = parse(
      ~S(
        test {a = 1
              b = 2}
      ))
  end

  test "parse: simple object merging" do
    assert {:ok, %{test: 1}} = parse(
      ~S(
        test {}, test = 1
      ))

    assert {:ok, %{test: %{}}} = parse(
      ~S(
        test = 1, test {}
      ))

    assert {:ok, %{test: %{a: 1, b: 2}}} = parse(
      ~S(
         test {a = 1}, test {b = 2}
      ))
  end

  test "parse: objects" do
    assert {:ok, %{a: %{a: 1}, b: %{b: 2}}} = parse(
      ~S(
        a {a = 1}, b {b = 2}
      ))

    assert {:ok, %{a: %{a: 1}, b: %{b: 2}}} = parse(
      ~S(
        a {a = 1},
        b {b = 2}
      ))

    assert {:ok, %{a: %{a: 1}, b: %{b: 2}}} = parse(
      ~S(
        a {a = 1}
        b {b = 2}
      ))

    assert {:ok, %{a: %{a: 1}, b: %{b: 2}}} = parse(
      ~S(
        a {a = 1}, # comment
        b {b = 2}
      ))

    assert {:ok, %{a: %{a: 1}, b: %{b: 2}}} = parse(
      ~S(
        a {a = 1} // comment
        b {b = 2}
      ))

    assert {:ok, %{a: %{a: 1}, b: %{b: 2}}} = parse(
      ~S(
        a {a = 1} /* comment
        */ b {b = 2}
      ))

    assert {:ok, %{a: %{a: 1}, b: %{b: 2, c: 3}}} = parse(
      ~S(
        a {a = 1},
        b {b = 2, c = 3}
      ))
  end



  test "parse vault config" do
    assert {:ok,
            %{deamon: true,
              backend: %{
                "consul" => %{address: "127.0.0.1:8500", path: "vault"}},
              listener: %{
                "tcp" => %{address: "127.0.0.1:8200", tls_disable: 1}},
              telemetry: %{
                disable_hostname: true, statsite_address: "127.0.0.1:8125"}}} = parse(
    ~S<
      deamon = true

      // Store data within Consul. This backend supports HA.
      // It is the most recommended backend for Vault and has been shown to
      // work at high scale under heavy load.
      backend "consul" {
        address = "127.0.0.1:8500"
        path = "vault"
      }

      /* Configures how Vault is listening for API requests.
      * "tcp" is currently the only option available.
      * A full reference for the inner syntax is below. */
      listener "tcp" {
        address = "127.0.0.1:8200"
        tls_disable = 1
      }

      # Configures the telemetry reporting system (see below).
      telemetry {
        statsite_address = "127.0.0.1:8125"
        disable_hostname = true
      }
    >)
  end
end
