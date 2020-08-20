# frozen_string_literal: true

require 'spec_helper'

describe 'class parameter indentation' do
  let(:msg) { 'expected newline at the end of the file' }

  context 'with fix disabled' do
    context 'when contains no parameters' do
      let(:code) { 'class foo::bar { }' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end
end
