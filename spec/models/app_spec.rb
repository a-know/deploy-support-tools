require 'spec_helper'

describe App do
  let(:store) { ActiveSupport::Cache::MemoryStore.new }
  let(:name) { 'awesome-application' }
  let(:max_entries) { 3 }
  let(:app) { App.new name, max_entries, store }

  describe '#lottery' do
    it '1st' do
      expect(app.lottery 'foo').to eq 1
    end

    it '2nd' do
      app.lottery 'foo'
      expect(app.lottery 'foo').to eq 1
    end

    it 'alt' do
      app.lottery 'foo'
      expect(app.lottery 'bar').to eq 2
    end

    it 'alt' do
      app.lottery 'foo'
      app.lottery 'bar'
      expect(app.lottery 'foo').to eq 1
    end

    it 'overflow' do
      app.lottery 'foo' # => 1
      app.lottery 'bar' # => 2
      app.lottery 'baz' # => 3
      expect(app.lottery 'yah').to eq 1
    end

    it 'rollover' do
      app.lottery 'foo' # => 1
      app.lottery 'bar' # => 2
      app.lottery 'baz' # => 3
      app.lottery 'yah' # => 1
      expect(app.lottery 'foo').to eq 2
    end

    context 'trimmed' do
      let(:dec) { App.new name, max_entries - 1, store }

      before do
        app.lottery 'foo' # => 1
        app.lottery 'bar' # => 2
        app.lottery 'baz' # => 3
        app.save
      end

      it '1st' do
        expect(dec.lottery 'foo').to eq 1
      end

      it '2nd' do
        expect(dec.lottery 'bar').to eq 2
      end

      it 'trimmed' do
        expect(dec.lottery 'baz').to eq 1
      end
    end

    context 'increase' do
      let(:inc) { App.new name, max_entries + 1, store }

      before do
        app.lottery 'foo' # => 1
        app.lottery 'bar' # => 2
        app.lottery 'baz' # => 3
        app.save
      end

      it 'old' do
        expect(inc.lottery 'foo').to eq 1
        expect(inc.lottery 'bar').to eq 2
        expect(inc.lottery 'baz').to eq 3
      end

      it 'new' do
        expect(inc.lottery 'woo').to eq 4
      end

      it 'new and old' do
        expect(inc.lottery 'woo').to eq 4
        expect(inc.lottery 'foo').to eq 1
        expect(inc.lottery 'yah').to eq 2
      end
    end
  end
end
