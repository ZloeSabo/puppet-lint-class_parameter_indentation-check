# frozen_string_literal: true

PuppetLint.new_check(:class_parameter_indentation) do
  OPENING_BRACKET_TYPES = [:LBRACK, :LBRACE].freeze # , :LPAREN]
  CLOSING_BRACKET_TYPES = [:RBRACK, :RBRACE].freeze
  VARIABLE_DEFINITION_TYPES = [:VARIABLE, :CLASSREF].freeze
  INDENT_TYPES = [:INDENT, :WHITESPACE].freeze
  MISSING_INDENT = 'missing_indent'
  INVALID_INDENT = 'invalid_indent'
  MISSING_NEWLINE = 'missing_newline'

  EXPECTED_INDENT = 2

  def check
    class_indexes.each do |class_idx|
      next if class_idx[:param_tokens].nil?

      resource_tokens = class_idx[:param_tokens]

      # need to count brackets to avoid checking inside types of complex types
      # like Variable[undef, Enum['yes', 'no'], false]
      open_brackets = 0

      skip_next_variable = false
      class_token = class_idx[:tokens].first
      expected_ws_len = class_token.column + 1

      resource_tokens.each do |token|
        # block for skipping comma separated data type definitions
        if OPENING_BRACKET_TYPES.include?(token.type)
          open_brackets += 1
          next
        end

        if CLOSING_BRACKET_TYPES.include?(token.type)
          open_brackets -= 1
          next
        end

        next if open_brackets.positive? # end of skipping comma separated data types

        if token.type == :VARIABLE && skip_next_variable
          skip_next_variable = false
          next
        end

        # If variable has type defined, we check indent of the type definition
        # leaving alignment of type to variable to other plugins
        if token.type == :CLASSREF
          skip_next_variable = true
        end

        next unless VARIABLE_DEFINITION_TYPES.include?(token.type)

        prev = token.prev_token
        unless INDENT_TYPES.include?(prev.type)
          notify(
            :warning,
            message: "indentation of #{token.value} (line: #{token.line} col: #{token.column}) is wrong. Expected indent of #{EXPECTED_INDENT} spaces from the title",
            line: token.line,
            column: token.column,
            token: token,
            issue_type: MISSING_INDENT,
            expected_ws_len: expected_ws_len,
          )
        end

        if INDENT_TYPES.include?(prev.type) && (token.column - class_token.column) != EXPECTED_INDENT
          notify(
            :warning,
            message: "indentation of #{token.value} (line: #{token.line} col: #{token.column}) is wrong. Expected indent of #{EXPECTED_INDENT} spaces from the title",
            line: token.line,
            column: token.column,
            token: token,
            issue_type: INVALID_INDENT,
            expected_ws_len: expected_ws_len,
          )
        end

        prevprev = prev&.prev_token

        next unless prevprev.type != :NEWLINE

        notify(
          :warning,
          message: "indentation of #{token.value} (line: #{token.line} col: #{token.column}) is wrong. Expected it to be on a new line",
          line: token.line,
          column: token.column,
          token: token,
          issue_type: MISSING_NEWLINE,
        )
      end
    end
  end

  def fix(problem)
    if problem[:issue_type] == INVALID_INDENT
      prevprev = problem[:token].prev_token.prev_token
      tokens.delete(problem[:token].prev_token)
      problem[:token].prev_token = prevprev
      # prevprev.next_token = problem[:token]
    end

    if [INVALID_INDENT, MISSING_INDENT].include?(problem[:issue_type])
      new_ws = ' ' * problem[:expected_ws_len]
      index = tokens.index(problem[:token].prev_token)
      tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:WHITESPACE, new_ws, 0, 0))
    end

    return unless problem[:issue_type] == MISSING_NEWLINE

    index = tokens.index(problem[:token].prev_code_token)
    tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))
  end
end
