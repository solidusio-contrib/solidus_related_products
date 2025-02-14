# frozen_string_literal: true

RSpec.describe 'Admin Relation Types', :js do
  stub_authorization!

  before do
    visit spree.admin_relation_types_path
  end

  it 'when no relation types exists' do
    expect(page).to have_text /NO RELATION TYPES FOUND, ADD ONE!/i
  end

  context 'create' do
    it 'can create a new relation type' do
      click_link 'New Relation Type'
      expect(page).to have_current_path spree.new_admin_relation_type_path, ignore_query: true

      fill_in 'Name', with: 'Gears'
      fill_in 'Applies From', with: 'Spree:Products'
      fill_in 'Applies To', with: 'Spree:Products'

      click_button 'Create'

      expect(page).to have_text 'successfully created!'
      expect(page).to have_current_path spree.admin_relation_types_path, ignore_query: true
    end

    it 'shows bidirectional checkbox' do
      click_link 'New Relation Type'

      expect(page).to have_field 'Bi-Directional'
    end

    it 'shows validation errors with blank :name' do
      click_link 'New Relation Type'
      expect(page).to have_current_path spree.new_admin_relation_type_path, ignore_query: true

      fill_in 'Name', with: ''
      click_button 'Create'

      expect(page).to have_text 'Name can\'t be blank'
    end

    it 'shows validation errors with blank :applies_from' do
      click_link 'New Relation Type'
      expect(page).to have_current_path spree.new_admin_relation_type_path, ignore_query: true

      fill_in 'Name', with: 'Gears'
      fill_in 'Applies From', with: ''
      click_button 'Create'

      expect(page).to have_text 'Applies from can\'t be blank'
    end

    it 'shows validation errors with blank :applies_to' do
      click_link 'New Relation Type'
      expect(page).to have_current_path spree.new_admin_relation_type_path, ignore_query: true

      fill_in 'Name', with: 'Gears'
      fill_in 'Applies To', with: ''
      click_button 'Create'

      expect(page).to have_text 'Applies to can\'t be blank'
    end
  end

  context 'with records' do
    before do
      %w(Gears Equipments).each do |name|
        create(:product_relation_type, name: name)
      end
      visit spree.admin_relation_types_path
    end

    context 'show' do
      it 'displays existing relation types' do
        within_row(1) do
          expect(column_text(1)).to eq 'Gears'
          expect(column_text(2)).to eq 'Spree::Product'
          expect(column_text(3)).to eq 'Spree::Product'
          expect(column_text(4)).to eq ''
        end
      end
    end

    context 'edit' do
      before do
        within_row(1) { click_icon :edit }
        expect(page).to have_current_path(spree.edit_admin_relation_type_path(1))
      end

      it 'does not show bidirectional checkbox' do
        expect(page).not_to have_field 'Bi-Directional'
      end

      it 'can update an existing relation type' do
        fill_in 'Name', with: 'Gadgets'
        click_button 'Update'
        expect(page).to have_text 'successfully updated!'
        expect(page).to have_text 'Gadgets'
      end

      it 'shows validation errors with blank :name' do
        fill_in 'Name', with: ''
        click_button 'Update'
        expect(page).to have_text 'Name can\'t be blank'
      end
    end

    context 'delete' do
      it 'can remove records' do
        accept_confirm do
          within_row(1) do
            expect(column_text(1)).to eq 'Gears'
            click_icon :trash
          end
        end
        expect(page).to have_text 'successfully removed!'
      end
    end
  end
end
