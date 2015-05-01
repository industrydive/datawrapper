<?php


require_once ROOT_PATH . 'lib/utils/themes.php';
require_once ROOT_PATH . 'vendor/jsmin/jsmin.php';


/*
 * PUBLISH STEP - shows progress of publishing action and thumbnail generation
 * forwards to /chart/:id/finish
 */
$app->get('/chart/:id/publish', function ($id) use ($app) {
    disable_cache($app);

    check_chart_writable($id, function($user, $chart) use ($app) {

        $cfg = $GLOBALS['dw_config'];

        $page = array(
            'title' => $chart->getID() . ' :: '.__('Publish'),
            'chartData' => $chart->loadData(),
            'chart' => $chart,
            'visualizations' => DatawrapperVisualization::all(),
            'vis' => DatawrapperVisualization::get($chart->getType()),
            'chartUrl' => $chart->getPublicUrl(),
            'chartUrlLocal' => '/chart/' . $chart->getID() . '/preview',
            'themes' => DatawrapperTheme::all(),
            'exportStaticImage' => !empty($cfg['phantomjs']),
            'chartActions' => DatawrapperHooks::execute(DatawrapperHooks::GET_CHART_ACTIONS, $chart),
            'estExportTime' => ceil(JobQuery::create()->estimatedTime('export_image') / 60)
        );
        // TODO: check for export-auto-png actually being installed
        $page['chartImgUrl'] = str_replace('index.html','chart.png',$chart->getPublicUrl());
        add_header_vars($page, 'chart', 'chart-editor/publish.css');
        add_editor_nav($page, 4);

        if ($user->isAbleToPublish()
            && ($chart->getLastEditStep() == 3 || $app->request()->get('republish') == 1)) {
            // actual publish process
            $chart->publish();
            $page['chartUrl'] = $chart->getPublicUrl();

            // generate thumbnails
            $page['publish'] = true;
            $page['republish'] = $app->request()->get('republish') == 1;
        }
        $app->render('chart/publish.twig', $page);

    });
});

