# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ -> 
    if $('#bracket-container').length
        $('#refresh').click()

    $("body").on "hidden.bs.modal", "#matchScoreModal", ->
        $('#matchScoreModal').remove()    

    $(document).on "click", "button.match-score-button", ->
        tournament_id = $("div#tournament-info").data("id")
        match = $(this).parent()
        match_id = $(match).data("match-id")
        stage = $(match).data("stage")
        team_a = $(match).find(".team-name").first().html()
        team_b = $(match).find(".team-name").last().html()

        $("body").append '<div class="modal fade" id="matchScoreModal" tabindex="-1" role="dialog">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                        <h4 class="modal-title">Insert score</h4>
                                    </div>
                                    <div class="modal-body">
                                        <h3>'+team_a+' : '+team_b+'</h3>
                                        <form action="/tournament/'+tournament_id+'/insert_match_score" method="post" data-remote="true">
                                            <input type="hidden" name="match_id" value="'+match_id+'">
                                            <input type="hidden" name="stage" value="'+stage+'">
                                            <h3><input type="number" name="score_a" min="0" value="0" required> : <input type="number" name="score_b" min="0" value="0" required></h3>
                                            <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                                            <button type="submit" class="btn btn-primary">Insert</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                          </div>'
        $("#matchScoreModal").modal()

    $(document).on "mouseenter", ".team", ->
        if(id = $(this).data("participant-id"))
            $(".brackets .team[data-participant-id="+id+"]").each( ->
                $(this).addClass("team-hover")            
            )
            

    $(document).on "mouseleave", ".team", ->
        if(id = $(this).data("participant-id"))
            $(".brackets .team[data-participant-id="+id+"]").each( ->
                $(this).removeClass("team-hover")            
            )