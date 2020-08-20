# frozen_string_literal: true

require 'spec_helper'

describe 'class_parameter_indentation' do
  let(:msg) { 'expected indentation of two spaces from the title' }

  context 'with fix disabled' do
    context 'when contains no parameters' do
      let(:code) { 'class foo::bar { }' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'when code contains wrong indentation in multiple lines' do
      let(:code) do
        <<-CODE
        class bar($someparam => 'somevalue',
          $another,$nope,Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port
              # $aaa,
              String  $third => 'meh',
        ) {
        }
        CODE
      end

      it 'detects eight problems' do # 4 wrong indents + 3 missing new lines
        expect(problems).to have(7).problem
      end

      it 'creates warnings' do
        expect(problems).to contain_warning('indentation of someparam (line: 1 col: 19) is wrong. Expected indent of 2 spaces from the title').on_line(1).in_column(19)
        expect(problems).to contain_warning('indentation of nope (line: 2 col: 20) is wrong. Expected indent of 2 spaces from the title').on_line(2).in_column(20)
        expect(problems).to contain_warning('indentation of Variant (line: 2 col: 26) is wrong. Expected indent of 2 spaces from the title').on_line(2).in_column(26)
        expect(problems).to contain_warning('indentation of String (line: 4 col: 15) is wrong. Expected indent of 2 spaces from the title').on_line(4).in_column(15)
        expect(problems).to contain_warning('indentation of someparam (line: 1 col: 19) is wrong. Expected it to be on a new line').on_line(1).in_column(19)
        expect(problems).to contain_warning('indentation of nope (line: 2 col: 20) is wrong. Expected it to be on a new line').on_line(2).in_column(20)
        expect(problems).to contain_warning('indentation of Variant (line: 2 col: 26) is wrong. Expected it to be on a new line').on_line(2).in_column(26)
      end
    end
  end

  context 'with fix enabled' do
    before(:each) do
      PuppetLint.configuration.fix = true
    end

    after(:each) do
      PuppetLint.configuration.fix = false
    end

    context 'when code contains wrong indentation in multiple lines' do
      let(:code) do
        <<-CODE
        class bar($someparam => 'somevalue',
          $another, $nope,Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port,
              # $aaa,
              String  $third => 'meh',
        ) {
        }
        CODE
      end

      let(:fixed) do
        <<-CODE
        class bar(
          $someparam => 'somevalue',
          $another,
          $nope,
          Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port,
              # $aaa,
          String  $third => 'meh',
        ) {
        }
        CODE
      end

      it 'fixes the code' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
