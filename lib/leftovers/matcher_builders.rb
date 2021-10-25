# frozen-string-literal: true

module Leftovers
  module MatcherBuilders
    autoload(:AndNot, "#{__dir__}/matcher_builders/and_not")
    autoload(:And, "#{__dir__}/matcher_builders/and")
    autoload(:Name, "#{__dir__}/matcher_builders/name")
    autoload(:Node, "#{__dir__}/matcher_builders/node")
    autoload(:NodeHasArgument, "#{__dir__}/matcher_builders/node_has_argument")
    autoload(:NodeHasKeywordArgument, "#{__dir__}/matcher_builders/node_has_keyword_argument")
    autoload(:NodeHasPositionalArgument, "#{__dir__}/matcher_builders/node_has_positional_argument")
    autoload(:NodeHasReceiver, "#{__dir__}/matcher_builders/node_has_receiver")
    autoload(:NodeName, "#{__dir__}/matcher_builders/node_name")
    autoload(:NodePairName, "#{__dir__}/matcher_builders/node_pair_name")
    autoload(:NodePairValue, "#{__dir__}/matcher_builders/node_pair_value")
    autoload(:NodePath, "#{__dir__}/matcher_builders/node_path")
    autoload(:NodeType, "#{__dir__}/matcher_builders/node_type")
    autoload(:NodeValue, "#{__dir__}/matcher_builders/node_value")
    autoload(:Or, "#{__dir__}/matcher_builders/or")
    autoload(:Path, "#{__dir__}/matcher_builders/path")
    autoload(:StringPattern, "#{__dir__}/matcher_builders/string_pattern")
    autoload(:String, "#{__dir__}/matcher_builders/string")
    autoload(:Unless, "#{__dir__}/matcher_builders/unless")
  end
end
