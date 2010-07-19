
#
# testing rufus-json
#
# Fri Jul 31 13:05:37 JST 2009
#

require 'test/unit'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rufus/json'
require 'rubygems'

JSON_LIB = ARGV[0]
require JSON_LIB

if JSON_LIB == 'active_support'
  Rufus::Json.backend = :active
else
  Rufus::Json.detect_backend
end

puts
puts "  #{Rufus::Json.backend.to_s.upcase} (#{JSON_LIB})"
puts


class DoTest < Test::Unit::TestCase

  #def setup
  #end

  def test_backend

    target = JSON_LIB.to_sym
    target = :active if target == :active_support
    target = :json if JSON_LIB == 'json/pure'

    assert_equal target, Rufus::Json.backend
  end

  def test_decode

    assert_equal [ 1, 2, 3 ], Rufus::Json.decode("[ 1, 2, 3 ]")
  end

  def test_encode

    assert_equal "[1,2,3]", Rufus::Json.encode([ 1, 2, 3 ])
  end

  def test_dup

    d0 = { 'id' => 'nada' }
    d1 = { :id => :nada }

    assert_equal({ 'id' => 'nada' }, Rufus::Json.dup(d0))
    assert_equal({ 'id' => 'nada' }, Rufus::Json.dup(d1))
  end

  def test_deep_nesting

    s = "{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{\"a\":{}}}}}}}}}}}}}}}}}}}}}}"

    h = {}
    p = h
    (1..21).each do |i|
      p['a'] = {}
      p = p['a']
    end

    assert_equal(s, Rufus::Json.encode(h))
    assert_equal(h, Rufus::Json.decode(s))
  end

  def test_parser_error

    return if Rufus::Json.backend == :active

    s = '{foo:cx1234}'

    assert_raise Rufus::Json::ParserError do
      p Rufus::Json.decode(s)
    end
  end

  def test_json_atoms

    [
      [ '1', 1 ],
      [ '1.1', 1.1 ],
      [ '1.1e10', 1.1e10 ],
      [ '1.1E10', 1.1e10 ],
      [ '1.1E-10', 1.1e-10 ],
      [ '"a"', 'a' ],
      [ 'true', true ],
      [ 'false', false ],
      [ 'null', nil ]
    ].each do |s, v|
      assert_equal v, Rufus::Json.decode(s)
    end
  end

  def test_pretty_encode

    s = Rufus::Json.pretty_encode(
      { 'a' => 'b', 'e' => [ 1, 2, 3 ], 'c' => { 'd' => true } })

    assert(s.index("\n")) if JSON_LIB != 'active_support'
  end
end

