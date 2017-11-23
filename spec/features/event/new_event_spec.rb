require'rails_helper'

describe "new event page", type: :feature do
	
	it "should render without an error" do
		visit new_event_path
	end

	it "should be possible to enter date conditions for an event" do
		visit new_event_path

		expect(page).to have_field("Deadline")
		expect(page).to have_field("Startdate")
		expect(page).to have_field("Enddate")
		expect(page).to have_field("Duration")
  end

  it "should be possible to create a date conditions for an event" do
		visit new_event_path

		fill_in "event_deadline", with: Date.tomorrow.to_s
		fill_in "event_startdate", with: (Date.tomorrow + 2).to_s
		fill_in "event_enddate", with: (Date.tomorrow + 3).to_s
		fill_in "event_duration", with: "2"

		find('input[type="submit"]').click

    expect(page).to have_current_path(/.*\/events\/\d+/)
		expect(page).to have_content(Date.tomorrow.to_s)
		expect(page).to have_content((Date.tomorrow + 2).to_s)
		expect(page).to have_content((Date.tomorrow + 3).to_s)
  end

end