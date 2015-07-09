<script type="text/javascript">
    var jq = jQuery;
    var navigationIndex = 1;
    var peviousIndex = 0;
    var wasGoingNext = true;
    var categoryFilterLabel = "";
    var reversed = false;
    
    jq(document).ready(function() {
    
		jq('#searchText').focus();
		jq("#chart-previous-searches-display").hide();
		jq("#custom-date-dialog-content").hide();
		jq("#ui-datepicker-start").datepicker();
		jq("#ui-datepicker-stop").datepicker();
		
		showHistorySuggestionsOnLoad();
		displayBothPersonalAndGlobalNotes();
		updateCategeriesAtUIGlobally(jsonAfterParse.appliedCategories);
		
        jq( "#date_filter_title" ).click(function() {
            jq( "#date_filter_options" ).toggle();
        });
        
        jq("#chart-searches-suggestions").hide();

        jq( "#date_filter_options" ).click(function(e) {
            jq( "#date_filter_options" ).hide();
            var txt = jq(e.target).text();
            jq("#date_filter_title").text(txt);
        });
        
        jq('#selectAll_categories').click(function (event) {
		    console.log(jq('.category_check'));
		    jq('.category_check').prop('checked', true);
		    categoryFilterLabel = "All Categories";
		    jq("#category-filter_method").text(categoryFilterLabel);
		    submitChartSearchFormWithAjax();
		    
		    return false;
		});
		
		jq('#deselectAll_categories').click(function (event) {
		    jq('.category_check').prop('checked', false);
		    categoryFilterLabel = "All Categories";
		    jq("#category-filter_method").text(categoryFilterLabel);
		    submitChartSearchFormWithAjax();
		    
		    return false;
		});
		
		jq("body").on("click", "#inside_filter_categories", function (event) {
			var currCatLinkId = event.target.id;
			var currCatCheckId = currCatLinkId.replace("select_","");
			
			if(event.target.localName === "a") {
				var currCatLabel = currCatCheckId.replace("_category", "");
				
				jq('#inside_filter_categories').find('input[type=checkbox]:checked').prop('checked', false);
				jq("#category-filter_method").text(capitalizeFirstLetter(currCatLabel));
			    jq("#" + currCatCheckId).prop('checked', true);
			    submitChartSearchFormWithAjax();
				jq('#filter_categories_categories').removeClass('display_filter_onclick');
				
				return false;
			} else if(event.target.localName === "input" && currCatLinkId) {
					var cat = jq("#" + currCatCheckId).val();
					
					if(jq("#" + currCatCheckId).attr('checked')) {
						var checkedCats = jq('#inside_filter_categories :checked');
						checkedCats.each(function() {
							if(categoryFilterLabel === "All Categories") {
								categoryFilterLabel = "";
							}
							var bothCombined = categoryFilterLabel + cat;
							if(categoryFilterLabel.indexOf(capitalizeFirstLetter(cat)) < 0) {
								if(bothCombined.length <= 14) {
					    			categoryFilterLabel += capitalizeFirstLetter(cat) + ",";
					    		} else {
					    			if(categoryFilterLabel.indexOf(capitalizeFirstLetter("...")) < 0) {
					    				categoryFilterLabel += "...";
					    			}
					    		}
					    	}
					    });
			    } else {
			    	if(categoryFilterLabel.indexOf(capitalizeFirstLetter(cat)) >= 0) {
			    		var cat2 = capitalizeFirstLetter(cat) + ",";
			    		categoryFilterLabel = categoryFilterLabel.replace(cat2, "");
			    	}
			    }
			    
			    if(categoryFilterLabel.indexOf("...") >= 0) {
					categoryFilterLabel = categoryFilterLabel.replace("...", "") + "...";
				}
				
				if(categoryFilterLabel === "..." || categoryFilterLabel === "" || categoryFilterLabel === ",...") {
					categoryFilterLabel = "All Categories";
				}
				
				jq("#category-filter_method").text(categoryFilterLabel);
			}
		});
		
		jq('#searchBtn').click(function(event) {
			submitChartSearchFormWithAjax();
			return false;
		});
		
		jq('#submit_selected_categories').click(function(event) {
			submitChartSearchFormWithAjax();
			jq('#filter_categories_categories').removeClass('display_filter_onclick');
			
			return false;
		});
		
		jq('.filter_method').click(function(event) {
			return false;
		});
		
		jq('#category_dropdown').on('click', function(e){
			if(e.target.localName !== "a" && e.target.localName !== "input") {
		    	jq('#filter_categories_categories').toggleClass('display_filter_onclick');
		    }
		});
		jq('#hide_categories').on('click', function(e){
		    jq('#filter_categories_categories').removeClass('display_filter_onclick');
		    return false;
		});
		
		jq('#time_dropdown').on('click', function(e){
		    jq('#filter_categories_time').toggleClass('display_filter_onclick');
		});
		
		jq('#location_dropdown').on('click', function(e){
		    jq('#locationOptions').toggleClass('display_filter_onclick');
		});
		
		jq('#provider_dropdown').on('click', function(e){
		    jq('#providersOptions').toggleClass('display_filter_onclick');
		});
		
		jq("#chart-previous-searches").click(function(event) {
			if(jq("#chart-previous-searches-display").is(':visible')) {
				jq("#chart-previous-searches-display").hide();
			} else {
				jq("#chart-previous-searches-display").show();
			}
		});
		
		jq("#searchText").keyup(function(key) {
			var searchText = document.getElementById('searchText').value;
			
			if(jq("#chart-previous-searches-display").is(':visible') && jsonAfterParse.searchHistory.length !== 0) {//Suggest History
				if(key.keyCode == 27) {
					submitChartSearchFormWithAjax();
				} else if(key.keyCode == 39 || key.keyCode == 37) {
			    	//DO NOTHING, since here we are doing
			    } else if ((key.keyCode >= 48 && key.keyCode <= 90) || key.keyCode != 13 || key.keyCode == 8) {//use numbers and letters plus backspace only
			    	delay(function() {
						if (searchText != "" && searchText.length >= 1) {
							updateSearchHistoryDisplay();
					 	} else {
					 		updateSearchHistoryDisplay();
					 	}
				    }, 50 );
			    }
			} else {//Suggest from default search suggestions
				updateSearchHistoryDisplay();
				if(key.keyCode == 27) {
			    	submitChartSearchFormWithAjax();
			    } else if(key.keyCode == 39 || key.keyCode == 37) {
			    	//DO NOTHING, since here we are doing
			    } else if ((key.keyCode >= 48 && key.keyCode <= 90) || key.keyCode != 13 || key.keyCode == 8) {//use numbers and letters plus backspace only
					delay(function() {
						if (searchText != "" && searchText.length >= 2) {
							showSearchSuggestions();
					 	} else {
					 		hideSearchSuggestions();
					 	}
				    }, 50 );
			    }
		    }
		    
			return false;
		});
		
		jq("body").on("click", "#chart-searches-suggestions", function (event) {
			if(event.target.localName === "a") {
				if(event.target.id === "hide-search-suggestions-ui") {
					jq("#chart-searches-suggestions").hide();
				} else {
					var selectedSuggestion = event.target.innerText;
					
					jq('#searchText').val(selectedSuggestion);
					submitChartSearchFormWithAjax();
				}
			}
			return false;
		});
		
		jq("body").on("click", "#chart-previous-searches-display", function (event) {
			if(event.target.localName === "a") {
				var selectedHistory = event.target.innerText;
				
				jq('#searchText').val(selectedHistory);
				unSelectAllCategories();
				submitChartSearchFormWithAjax();
			} else if(event.target.localName === "i") {
				var uuid = event.target.id;
				if(uuid) {
					deleteSearchHistory(uuid);
				}
			}
			return false;
		});
		
		var delay = (function() {
		  var timer = 0;
		  return function(callback, ms){
		    clearTimeout (timer);
		    timer = setTimeout(callback, ms);
		  };
		})();
		
		jq(document).keydown(function(key) {//TODO https://issues.openmrs.org/browse/CSM-101
			//TODO update navigationIndex variable after load_single_detailed_obs(...)
			var single_obsJSON = jsonAfterParse.obs_singles;
			
			if (typeof single_obsJSON !== 'undefined') {
				if(key.keyCode == 39) {// =>>
					var diffBtnIndecs = navigationIndex - peviousIndex;
					var numberOfResults = jsonAfterParse.obs_groups.length + jsonAfterParse.obs_singles.length + jsonAfterParse.patientAllergies.length + jsonAfterParse.patientAppointments.length;
					
					if(wasGoingNext) {
						if(navigationIndex != numberOfResults) {
							if(navigationIndex >= 0 && diffBtnIndecs == 1) {
								increamentNavigation(single_obsJSON);
							}
						}
					} else {
						navigationIndex  = navigationIndex + 2;
						if(peviousIndex == 0) {
							diffBtnIndecs = -1;
							navigationIndex = 1;
						}
						if(navigationIndex >= 0 && diffBtnIndecs == -1) {
							increamentNavigation(single_obsJSON);
						}
					}
				}
				if(key.keyCode == 37) {// <<=
					if(peviousIndex != 0) {
						var diffBtnIndecs = navigationIndex - peviousIndex;
						
						if(wasGoingNext) {
							navigationIndex  = navigationIndex - 2;
							
							if(navigationIndex >= 0 && diffBtnIndecs == 1) {
								decreamentNavigation(single_obsJSON);
							}
						} else {
							if(navigationIndex >= 0 && diffBtnIndecs == -1) {
								decreamentNavigation(single_obsJSON);
							}
						}
					}
				}
			}
		});
		
		jq("#ui-datepicker-stop").change(function(event) {
			var start = jq("#ui-datepicker-start").val();
			var stop = jq("#ui-datepicker-stop").val();
			var startDate = new Date(start);
			var stopDate = new Date(stop);
			
			if(stopDate.setHours(0, 0, 0, 0) > startDate.setHours(0, 0, 0, 0)) {
				jq("#submit-custom-date-filter").removeAttr('disabled');
			} else {
				jq("#submit-custom-date-filter").attr('disabled','disabled');
			}
		});
		
    });
    
		function submitChartSearchFormWithAjax() {
			if(isLoggedInSynchronousCheck()) {
				var searchText = document.getElementById('searchText');
				var searchHistory = jsonAfterParse.searchHistory;
				var patientId = jq("#patient_id").val().replace("Patient#", "");
				var categories = getAllCheckedCategoriesOrFacets();
				
				reInitializeGlobalVars();
				jq("#chart-previous-searches-display").hide();
				jq(".obsgroup_view").empty();
				jq("#found-results-summary").html('');
				jq("#obsgroups_results").html('<img class="search-spinner" src="../ms/uiframework/resource/uicommons/images/spinner.gif">');
				jq('.ui-dialog-content').dialog('close');	
				jq("#lauche-other-chartsearch-features").hide();
				jq("#lauche-stored-bookmark").hide();
				jq("#chart-previous-searches-display").hide();
				jq('#filter_categories_categories').removeClass('display_filter_onclick');
				
				jq.ajax({
					type: "POST",
					url: "${ ui.actionLink('getResultsFromTheServer') }",
					data: { "patientId":patientId, "phrase":searchText.value, "categories":categories },
					dataType: "json",
					success: function(results) {
						jq("#obsgroups_results").html('');
						jq(".inside_filter_categories").fadeOut(500);
										
						jsonAfterParse = JSON.parse(results);
						
						refresh_data(jsonAfterParse);
						storeJsonFromServer(jsonAfterParse);
						autoClickFirstResultToShowItsDetails(jsonAfterParse);
						
						jq(".results_table_wrap").fadeIn(500);
						jq(".inside_filter_categories").fadeIn(500);
								
						showHistorySuggestionsOnLoad();
						hideSearchSuggestions();
	    				displayBothPersonalAndGlobalNotes();
	    				displayQuickSearches();
	    				updateBookmarksAndNotesUI();
	    				updateCategeriesAtUIGlobally(jsonAfterParse.appliedCategories);
					},
					error: function(e) {
					  //alert("Error occurred!!! " + e);
					}
				});
			} else {
				location.reload();
			}
		}
		
		function increamentNavigation(single_obsJSON) {//TODO logic may not work for some instances
			var obs = single_obsJSON[navigationIndex];
			var allergy = jsonAfterParse.patientAllergies[navigationIndex - (jsonAfterParse.obs_groups.length + jsonAfterParse.obs_singles.length)];
			var appointment = jsonAfterParse.patientAppointments[navigationIndex - (jsonAfterParse.obs_groups.length + jsonAfterParse.obs_singles.length + jsonAfterParse.patientAllergies.length)];
							
			peviousIndex = navigationIndex;
			navigationIndex++;
			wasGoingNext = true;
			if(obs && obs.observation_id) {
				focusOnNextObsAndDisplayItsDetails(obs.observation_id);
			} else if(allergy && allergy.allergenId > 0) {
				focusOnNextAllergenAndDisplayItsDetails(allergy.allergenId);
			} else if(appointment && appointment.id > 0) {
				focusOnNextAppointmentAndDisplayItsDetails(appointment.id)
			}
		}
		
		function decreamentNavigation(single_obsJSON) {//TODO logic may not work for some instances
			var obs = single_obsJSON[navigationIndex];
			var allergy = jsonAfterParse.patientAllergies[navigationIndex - (jsonAfterParse.obs_groups.length + jsonAfterParse.obs_singles.length)];
			var appointment = jsonAfterParse.patientAppointments[navigationIndex - (jsonAfterParse.obs_groups.length + jsonAfterParse.obs_singles.length + jsonAfterParse.patientAllergies.length)];
								
			peviousIndex = navigationIndex;
			navigationIndex--;
			wasGoingNext = false;
								
			if(obs && obs.observation_id) {
				focusOnNextObsAndDisplayItsDetails(obs.observation_id);
			} else if(allergy && allergy.allergenId > 0) {
				focusOnNextAllergenAndDisplayItsDetails(allergy.allergenId);
			} else if(appointment && appointment.id > 0) {
				focusOnNextAppointmentAndDisplayItsDetails(appointment.id)
			}
		}
		
		function focusOnNextObsAndDisplayItsDetails(obsId) {
			jq('#obs_single_'+obsId).focus();
			load_single_detailed_obs(obsId);
		}
		
		function focusOnNextAllergenAndDisplayItsDetails(allergenId) {
			jq('#allergen_' + allergenId).focus();
			load_allergen(allergenId);
		}
		
		function focusOnNextAppointmentAndDisplayItsDetails(appId) {
			jq('#appointment_' + appId).focus();
			load_appointment(appId);
		}
		
		function hideSearchSuggestions() {
			jq("#chart-searches-suggestions").hide();
		}
		
		function showSearchSuggestions() {
			if(isLoggedInSynchronousCheck()) {
				var suggestionsArray = jsonAfterParse.searchSuggestions;
				var searchSuggestions = "";
				var searchText = jq('#searchText').val();
				
				searchSuggestions += "<a id='hide-search-suggestions-ui'>Close</a>";
				
				for(i = 0; i < suggestionsArray.length; i++) {
					var suggestion = suggestionsArray[i];
					
					if(strStartsWith(suggestion.toUpperCase(), searchText.toUpperCase()) && searchSuggestions.indexOf(suggestion) <= 0) {
						searchSuggestions += "<a class='search-text-suggestion' href=''>" + suggestion + "</a><br/>";
					}
				}
				
				document.getElementById('chart-searches-suggestions').innerHTML = searchSuggestions;
				if(searchSuggestions) {
					jq("#chart-searches-suggestions").show();
				} else {
					jq("#chart-searches-suggestions").hide();
				}
			} else {
				location.reload();
			}
		}
		
		function strStartsWith(str, prefix) {
		    return str.indexOf(prefix) === 0;
		}
		
		function showHistorySuggestionsOnLoad() {//TODO Rename this method to mention that it's for main page since we shall provide another for preference page
			var historyToDisplay = "";
			var history = jsonAfterParse.searchHistory.reverse();
			
			reversed = true;
			
			for(i = 0; i < history.length; i++) {
				historyToDisplay += "<div class='search-history-item'><a class='search-using-this-history' href=''>" + history[i].searchPhrase + "</a>&nbsp&nbsp-&nbsp&nbsp<em>" + history[i].formattedLastSearchedAt + "</em><i id='" + history[i].uuid + "' class='icon-remove delete-search-history' title='Delete This History'></i></div>"; 
			}
			
			jq("#chart-previous-searches-display").html(historyToDisplay);
		}
		
		function updateSearchHistoryDisplay() {
			if(isLoggedInSynchronousCheck()) {
				var historyArray;
				var historySuggestions = "";
				var searchText = jq('#searchText').val();
				
				if(reversed === true) {
					historyArray = jsonAfterParse.searchHistory
				} else {
					historyArray = jsonAfterParse.searchHistory.reverse();
					reversed = true;
				}
				
				for(i = 0; i < historyArray.length; i++) {
					var history = historyArray[i];
					
					if(strStartsWith(history.searchPhrase.toUpperCase(), searchText.toUpperCase()) && historySuggestions.indexOf(history) <= 0) {
						historySuggestions += "<div class='search-history-item'><a class='search-using-this-history' href=''>" + history.searchPhrase + "</a>&nbsp&nbsp-&nbsp&nbsp<em>" + history.formattedLastSearchedAt + "</em><i id='" + history.uuid + "' class='icon-remove delete-search-history'></i></div>";
					}
				}
				if(historySuggestions === "") {
					showSearchSuggestions();
				} else {
					hideSearchSuggestions();
				}
				
				document.getElementById('chart-previous-searches-display').innerHTML = historySuggestions;
			} else {
				location.reload();
			}
		}
		
		function deleteSearchHistory(historyUuid) {
			if(isLoggedInSynchronousCheck()) {
				if(historyUuid) {
					jq.ajax({
						type: "POST",
						url: "${ ui.actionLink('deleteSearchHistory') }",
						data: {"historyUuid":historyUuid},
						dataType: "json",
						success: function(updatedHistory) {
							var history = updatedHistory.searchHistory;
							
							jsonAfterParse.searchHistory = history;
							showHistorySuggestionsOnLoad();
						},
						error: function(e) {
							//DO Nothing
						}
					});
				}
			} else {
				location.reload();
			}
		}
</script>

<style type="text/css">
    .chart-search-input {
        background: #00463f;
        text-align: left;
        color: white;
        padding: 20px 30px;
        -moz-border-radius: 5px;
        -webkit-border-radius: 5px;
        -o-border-radius: 5px;
        -ms-border-radius: 5px;
        -khtml-border-radius: 5px;
        border-radius: 5px;
    }
    .chart_search_form_text_input {
        min-width: 82% !important;
    }
    .inline {
        display: inline-block;
    }
    .chart_search_form_button {
        margin-left: 30px;
    }
    .form_label_style {
        margin-bottom: 10px !important;
    }
    .filter_options {
        display: none;
        background: white;
        width: 90px;
        padding: 13px;
        position: absolute;
        border: 1px solid black;
        left:242px;
    }
    .date_filter_title {
        display: inline-block;
        white-space: nowrap;
        background-color: #ddd;
        background-image: -webkit-gradient(linear, left top, left bottom, from(#eee), to(#ccc));
        background-image: -webkit-linear-gradient(top, #eee, #ccc);
        background-image: -moz-linear-gradient(top, #eee, #ccc);
        background-image: -ms-linear-gradient(top, #eee, #ccc);
        background-image: -o-linear-gradient(top, #eee, #ccc);
        background-image: linear-gradient(top, #eee, #ccc);
        border: 1px solid #777;
        padding: 0 1.5em;
        margin: 0.5em 0;
        font: bold 1em/2em Arial, Helvetica;
        text-decoration: none;
        color: #333;
        text-shadow: 0 1px 0 rgba(255,255,255,.8);
        -moz-border-radius: .2em;
        -webkit-border-radius: .2em;
        border-radius: .2em;
        -moz-box-shadow: 0 0 1px 1px rgba(255,255,255,.8) inset, 0 1px 0 rgba(0,0,0,.3);
        -webkit-box-shadow: 0 0 1px 1px rgba(255,255,255,.8) inset, 0 1px 0 rgba(0,0,0,.3);
        box-shadow: 0 0 1px 1px rgba(255,255,255,.8) inset, 0 1px 0 rgba(0,0,0,.3);
    }
    .date_filter_title:hover
    {
        background-color: #eee;
        background-image: -webkit-gradient(linear, left top, left bottom, from(#fafafa), to(#ddd));
        background-image: -webkit-linear-gradient(top, #fafafa, #ddd);
        background-image: -moz-linear-gradient(top, #fafafa, #ddd);
        background-image: -ms-linear-gradient(top, #fafafa, #ddd);
        background-image: -o-linear-gradient(top, #fafafa, #ddd);
        background-image: linear-gradient(top, #fafafa, #ddd);
        cursor: pointer;
    }

    .date_filter_title:active
    {
        -moz-box-shadow: 0 0 4px 2px rgba(0,0,0,.3) inset;
        -webkit-box-shadow: 0 0 4px 2px rgba(0,0,0,.3) inset;
        box-shadow: 0 0 4px 2px rgba(0,0,0,.3) inset;
        position: relative;
        top: 1px;
    }
    .date_filter_title:after {
        content:' ↓'
    }
    .single_filter_option {
        display: block;
        cursor: pointer;
    }

    .demo-container {
        box-sizing: border-box;
        width: 400px;
        height: 300px;
        padding: 20px 15px 15px 15px;
        margin: 15px auto 30px auto;
        border: 1px solid #ddd;
        background: #fff;
        background: linear-gradient(#f6f6f6 0, #fff 50px);
        background: -o-linear-gradient(#f6f6f6 0, #fff 50px);
        background: -ms-linear-gradient(#f6f6f6 0, #fff 50px);
        background: -moz-linear-gradient(#f6f6f6 0, #fff 50px);
        background: -webkit-linear-gradient(#f6f6f6 0, #fff 50px);
        box-shadow: 0 3px 10px rgba(0,0,0,0.15);
        -o-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        -ms-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        -moz-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        -webkit-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
    }

    .demo-placeholder {
        width: 100%;
        height: 100%;
        font-size: 14px;
        line-height: 1.2em;
    }

    .legend, .legend div {
        display: none;
    }

    .bold {
        font-weight: bold;
    }
    
    .category_filter_item {
    
    }
    
    .search-spinner {
    	display: block;
   		margin-left: auto;
    	margin-right: auto;
    	padding-top: 230px;
    	height:120px;
    	width:120px;
    }
    
    #found_no_results {
    	text-align:center;
    	font-size: 25px;
    }
    
    #chart_search_form_inputs-searchPhrase {
    	position:relative;
    }
    
    #chart-previous-searches {
    	position:absolute;
    }
    
    #searchBtn {
    	margin-left:45px;
    }
    
    #chart-previous-searches {
    	cursor: pointer;
    }
    
    .filters_section, #category_dropdown, #time_dropdown, #location_dropdown, #provider_dropdown {
    	z-index: 0;
    }
    
    #chart-previous-searches-display {
    	position: absolute;
		z-index: 1;
		height: 250px;
		width: 775px;
		overflow: scroll;
		background-color: white;
		padding-left: 10px;
		padding-right: 5px;
		border-left: 2px solid #9C9A9A;
		color: #949494;
    }
    
    #chart-searches-suggestions {
    	position: absolute;
		z-index: 2;
		height: 108px;
		width: 764px;
		background-color: white;
		padding-left: 10px;
		border: 2px solid #007fff;
		color: black;
		overflow: hidden;
    }
    
    .search-text-suggestion {
    	cursor: pointer;
    }
    
    .category_filter_item-disabled {
    	pointer-events:none;
    }
    
    #found-results-summary {
    	color:rgb(131, 128, 128);
    	text-align:center;
    }
    
    .search-history-item {
		height: 25px;
		border-bottom: 1px solid #A8ACAC;
	}
	
    .delete-search-history {
    	float:right;
    	cursor: pointer;
    }
    
    #hide-search-suggestions-ui {
    	float:right;
    	padding-right:10px;
    	cursor:pointer;
    	color:rgb(79, 100, 155);
    }
    
	
</style>

<article id="search-box">
    <section>
        <div class="chart-search-wrapper">
            <form class="chart-search-form" id="chart-search-form-submit">
                <div class="chart-search-input">
                    <div class="chart_search_form_inputs">
                        <input type="text" name="patientId" id="patient_id" value=${patientId} hidden>
                        <div id="chart_search_form_inputs-searchPhrase">
                        	<input type="text" id="searchText" name="phrase" class="chart_search_form_text_input inline ui-autocomplete-input" placeholder="${ ui.message("chartsearch.messageInSearchField") }" size="40">
                        	<i id="chart-previous-searches" class="icon-arrow-down medium" title="History"></i>
                        	<input type="submit" id="searchBtn" class="button inline chart_search_form_button" value="search"/>
                        </div>
                        <div id="chart-previous-searches-display">
                        	<!-- All, search phrases searched to be stored and displayed here -->
                        </div>
                        <div id="chart-searches-suggestions">
                        </div>
                    </div>
                    <div class="filters_section">
                    	<div class="dropdown" id="category_dropdown">
	                     	<div class="inside_categories_filter">
								<span class="dropdown-name" id="categories_label">
								<a href="#" class="filter_method" id="category-filter_method">All Categories</a>
								<i class="icon-sort-down" id="icon-arrow-dropdown"></i>
								</span>
								<div class="filter_categories" id="filter_categories_categories">
									<a href="" id="selectAll_categories" class="disabled_link">Select All</a>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<a href="" id="deselectAll_categories" class="disabled_link">Clear</a>
									<br /><hr />
									<div id="inside_filter_categories">
										<script type="text/javascript">
											displayCategories(jsonAfterParse);
										</script>
									</div>
									<hr />
									<input id="submit_selected_categories" type="submit" value="OK" />&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<a href="" id="hide_categories">Cancel</a>
								</div>
							</div>
						</div>
                        <div class="dropdown" id="time_dropdown">
                            <div class="inside_categories_filter">
                                <span class="dropdown-name" id="time_label">
                                    <a href="#" class="filter_method" id="time_anchor">Any Time</a>
                                    <i class="icon-sort-down" id="icon-arrow-dropdown"></i>
                                </span>
                                <div class="filter_categories" id="filter_categories_time">
                                    <hr />
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('today')">Today</a>
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('yesterday')">Yesterday</a>
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('thisWeek')">This Week</a>
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('thisMonth')">This Month</a>
										<a class="single_filter_option" onclick="filterResultsUsingTime('last3Months')">Last 3 Months</a>
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('thisYear')">This Year</a>
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('custom')">Custom</a>
                                        <a class="single_filter_option" onclick="filterResultsUsingTime('anyTime')">Any Time</a>
                                </div>
                                <div id="custom-date-dialog-content">
                                	<p>Start: <input type="text" id="ui-datepicker-start"></p><br />
									<p>Stop: <input type="text" id="ui-datepicker-stop"></p><br />
									<p><input type="button" id="submit-custom-date-filter" value="Submit" disabled /></p>
                                </div>
                            </div>
                        </div>
                        <div class="dropdown" id="location_dropdown">
                            <div class="inside_categories_filter">
                                <span class="dropdown-name" id="categories_label">
                                    <a href="#" class="filter_method" id="location_anchor">All Locations</a>
                                    <i class="icon-sort-down" id="icon-arrow-dropdown"></i>
                                </span>
                                <div class="filter_categories" id="locationOptions">

                                </div>
                            </div>
                        </div>
                        <div class="dropdown" id="provider_dropdown">
                            <div class="inside_categories_filter">
                                <span class="dropdown-name" id="categories_label">
                                    <a href="#" class="filter_method" id="provider_anchor">All Providers</a>
                                    <i class="icon-sort-down" id="icon-arrow-dropdown"></i>
                                </span>
                                <div class="filter_categories" id="providersOptions">
                                    
                                </div>
                            </div>
                        </div>
                    	<div id="search-saving-section">
							${ ui.includeFragment("chartsearch", "searchSavingSection") }
						</div>
                    </div>
                </div>
    			${ ui.includeFragment("chartsearch", "main_results") }
            </form>
        </div>
    </section>
</article>