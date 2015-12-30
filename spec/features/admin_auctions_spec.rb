require 'rails_helper'

RSpec.feature "AdminAuctions", type: :feature do
  before do
    create_current_auction
    sign_in_admin
  end

  scenario "deleting an auction from the admin panel" do
    visit "/admin/auctions"

    expect(page).to have_selector(:link_or_button, 'Destroy')

    click_on("Destroy")

    expect(page).to_not have_text(@auction.title)
  end

  scenario "visiting the admin auctions list and then an auction" do
    visit "/admin/auctions"
    expect(page).not_to have_text('must be an admin')
    expect(page).to have_text(@auction.title)
    click_on(@auction.title)
    auction = Presenter::Auction.new(@auction)
    current_bid_amount = ApplicationController.helpers.number_to_currency(
      auction.current_bid.amount
    )

    expect(page).to have_text(current_bid_amount)
    expect(page).to have_text(@auction.description)
  end

  scenario "adding an auction" do
    visit "/admin/auctions"
    expect(page).not_to have_text('must be an admin')
    find_link('Create a new auction').click

    title = 'Build the micropurchase thing'
    fill_in("auction_title", with: title)
    fill_in("auction_description", with: 'and the admin related stuff')
    fill_in("auction_start_datetime", with: Presenter::DcTime.convert(Time.now + 3.days).strftime("%m/%d/%Y"))
    fill_in("auction_end_datetime", with: Presenter::DcTime.convert(Time.now - 3.days).strftime("%m/%d/%Y"))
    fill_in("auction_github_repo", with: "https://github.com/18F/calc")
    fill_in("auction_summary", with: "The Summary!")
    fill_in("auction_issue_url", with: "https://github.com/18F/calc/issues/255")
    click_on("Submit")

    expect(page).to have_text(@auction.title)
    expect(page).to have_text("Build the micropurchase thing")
    expect(page).to have_text(
      Presenter::DcTime.convert(Time.now + 3.days).
        beginning_of_day.strftime(Presenter::DcTime::FORMAT)
    )
  end

  scenario "updating an auction" do
    visit "/admin/auctions"
    click_on("Edit")

    title = 'Build the micropurchase thing'
    fill_in("auction_title", with: title)

    description = 'and the admin related stuff'
    fill_in("auction_description", with: description)

    github_repo = "https://github.com/18F/calc"
    fill_in("auction_github_repo", with: github_repo)

    summary = "The Summary!"
    fill_in("auction_summary", with: summary)

    issue_url = "https://github.com/18F/calc/issues/255"
    fill_in("auction_issue_url", with: issue_url)
    click_on("Submit")

    expect(page).to have_text(title)

    click_on(title)

    expect(page).to have_text(summary)
    expect(page).to have_text(description)
  end
end
